
module Flor

  class << self

    #
    # ids
    #
    # functions about exids, nids, sub_nids, ...

    def split_fei(fei)

      if m = fei.match(/\A([^-]+-[^-]+-\d+\.\d+\.[^-]+)-(.*)\z/)
        [ m[1], m[2] ]
      else
        [ nil ]
      end
    end

    def exid(fei)

      split_fei(fei).first
    end

    def split_nid(nid)

      nid.split('-')
    end

    def child_id(nid)

      nid ? nid.split('_').last.split('-').first.to_i : nil
    end

    def next_child_id(nid)

      child_id(nid) + 1
    end

    def sub_nid(nid, subid=nil)

      if subid
        "#{nid.split('-').first}-#{subid}"
      else
        ss = nid.split('-')
        ss.length > 1 ? ss.last.to_i : 0
      end
    end

    def same_sub?(nid0, nid1)

      sub_nid(nid0) == sub_nid(nid1)
    end

    def same_branch?(nid0, nid1)

      return false unless same_sub?(nid0, nid1)

      n0, n1 = [ nid0, nid1 ].collect { |i| Flor.master_nid(i) }.sort
      n = n1[0, n0.length]

      n == n0
    end

    # Remove the sub_nid if any.
    #
    def master_nid(nid)

      nid.split('-').first
    end

    def child_nid(nid, i, sub=nil)

      nid, subnid = nid.split('-')
      subnid = sub if sub && sub > 0

      "#{nid}_#{i}#{subnid ? "-#{subnid}" : ''}"
    end

    def parent_id(nid)

      if i = nid.rindex('_')
        nid[0, i]
      else
        nil
      end
    end

    def parent_nid(nid, remove_subnid=false)

      _, sub = nid.split('-')
      i = nid.rindex('_')

      return nil unless i
      "#{nid[0, i]}#{remove_subnid || sub.nil? ? nil : "-#{sub}"}"
    end

    def is_nid?(s)

      !! (s.is_a?(String) && s.match(/\A[0-9]+(?:_[0-9]+)*(?:-[0-9]+)?\z/))
    end

    def split_exid(s)

      return nil unless s.is_a?(String)

      _, d, u, t = s
        .match(/\A([^-\s]+)-([^-\s]+)-(\d{8,9}\.\d{4}\.[a-z]+)\z/)
        .to_a

      return nil unless d && u && t

      [ d, u, t ]
    end

    def is_exid?(s)

      !! split_exid(s)
    end

    # Returns [ exid, nid ]
    #
    def extract_exid_and_nid(s)

      m = s.match(/(\d{8}\.\d{4}\.[a-z]+)-(\d+(?:_\d+)*)(-\d+)?/)

      m ? [ m[1], [ m[2], m[3] ].compact.join ] : nil
    end
  end
end

