# frozen_string_literal: true

class Flor::Pro::Split < Flor::Procedure

  names %w[ split ]

  def pre_execute

    @node['rets'] = []

    unatt_unkeyed_children
  end

  def receive_last

    str = nil
    rex = nil
      #
    (@node['rets'] + [ node_payload_ret ])
      .each { |r|
        break if str && rex
        if r.is_a?(String)
          if str == nil
            str = r
          else
            rex ||= r
          end
        elsif Flor.is_regex_tree?(r)
          rex = Flor.to_regex(r)
        end }
      #
    rex ||= /\s+/

    fail Flor::FlorError.new("found no string to split", self) \
      if str == nil

    wrap('ret' => str.split(rex))
  end
end

