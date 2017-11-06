
module Flor

  #
  # ids
  #
  # functions about exids, nids, sub_nids, ...

  def self.split_fei(fei)

    if m = fei.match(/\A([^-]+-[^-]+-\d+\.\d+\.[^-]+)-(.*)\z/)
      [ m[1], m[2] ]
    else
      [ nil ]
    end
  end

  def self.exid(fei)

    split_fei(fei).first
  end

  def self.split_nid(nid)

    nid.split('-')
  end

  def self.child_id(nid)

    nid ? nid.split('_').last.split('-').first.to_i : nil
  end

  def self.next_child_id(nid)

    child_id(nid) + 1
  end

  def self.sub_nid(nid, subid=nil)

    if subid
      "#{nid.split('-').first}-#{subid}"
    else
      ss = nid.split('-')
      ss.length > 1 ? ss.last.to_i : 0
    end
  end

  # Remove the sub_nid if any.
  #
  def self.master_nid(nid)

    nid.split('-').first
  end

  def self.child_nid(nid, i, sub=nil)

    nid, subnid = nid.split('-')
    subnid = sub if sub && sub > 0

    "#{nid}_#{i}#{subnid ? "-#{subnid}" : ''}"
  end

  def self.parent_id(nid)

    if i = nid.rindex('_')
      nid[0, i]
    else
      nil
    end
  end

  def self.parent_nid(nid, remove_subnid=false)

    _, sub = nid.split('-')
    i = nid.rindex('_')

    return nil unless i
    "#{nid[0, i]}#{remove_subnid || sub.nil? ? nil : "-#{sub}"}"
  end

  def self.is_nid?(s)

    !! (s.is_a?(String) && s.match(/\A[0-9]+(?:_[0-9]+)*(?:-[0-9]+)?\z/))
  end

  # Returns [ exid, nid ]
  #
  def self.extract_exid_and_nid(s)

    m = s.match(/(\d{8}\.\d{4}\.[a-z]+)-(\d+(?:_\d+)*)(-\d+)?/)

    m ? [ m[1], [ m[2], m[3] ].compact.join ] : nil
  end
end

