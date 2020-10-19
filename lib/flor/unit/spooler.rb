# frozen_string_literal: true

module Flor

  class Spooler

    # NB: logger configuration entries start with "spo_"

    def initialize(unit)

      @unit = unit

      @dir = determine_spool_dir
    end

    def shutdown

      @dir = nil
    end

    def spool

      return -1 unless @dir

      Dir[File.join(@dir, '*.json')]
        .inject(0) do |count, path|

          begin
            File.open(path, 'rb') do |f|
              lock(path, f) or next
              accept(path, f) or next
              unlock(path, f)
            end
            count += 1
          rescue => err
            reject(path, err)
          end

          count
        end
    end

    protected

    def determine_spool_dir

      r = @unit.conf['root']
      return nil unless r

      d = File.join(r, @unit.conf['spo_dir'] || 'var/spool')
      return nil unless File.directory?(d)

      d
    end

    def lock(path, file)

      file.flock(File::LOCK_EX | File::LOCK_NB) == 0
    end

    def unlock(path, file)

      # nothing more to do
    end

    def accept(path, file)

      json = file.read

      return false if json == ''

      @unit.storage.put_message(JSON.parse(json))

      con = File.join(@dir, 'consumed')

      File.delete(path)

      return true unless File.directory?(con)

      fn = File.join(con, "#{File.basename(path, '.json')}.#{Flor.tamp}.json")

      File.open(fn, 'wb') { |f| f.write(json) }

      true
    end

    def reject(path, err)

      rej = File.join(@dir, 'rejected')

      FileUtils.mkdir_p(rej)

      eh = err.hash.abs
      ts = Flor.tamp

      jfn = File.join(
        rej, "#{File.basename(path, '.json')}__#{eh}_#{ts}.json")
      tfn = File.join(
        rej, "#{File.basename(path, '.json')}__#{eh}_#{ts}.txt")

      FileUtils.mv(path, jfn)

      File.open(tfn, 'wb') do |tf|
        tf.puts(err.inspect)
        tf.puts(err.class.to_s)
        tf.puts(err.to_s)
        tf.puts(err.backtrace)
      end
    end
  end
end

