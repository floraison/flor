
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
              accept(path, f)
              unlock(path, f)
            end
            count += 1
          rescue => err
p err
            reject(path)
          end

          count
        end
    end

    protected

    def determine_spool_dir

      d = @unit.conf['spo_dir'] || 'var/spool'
      d = File.join(@unit.conf['root'], d) if d
      d = nil unless File.directory?(d)

      d
    end

    def lock(path, file)

      file.flock(File::LOCK_EX | File::LOCK_NB) == 0
    end

    def unlock(path, file)

      File.delete(path)
        # nothing more to do
    end

    def accept(path, file)

      json = file.read

      @unit.storage.put_message(JSON.parse(json))

      con = File.join(@dir, 'consumed')

      return unless File.directory?(con)

      fn = "#{File.basename(path, '.json')}.#{Flor.tamp}.json"

      File.open(fn, 'wb') { |f| f.write(json) }
    end

    def reject(path)

      rej = File.join(@dir, 'rejected')

      return unless File.directory?(rej)

      FileUtils.mv(
        path,
        File.join(rej, "#{File.basename(path, '.json')}.#{Flor.tamp}.json"))
    end
  end
end

