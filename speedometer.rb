# -*- coding: utf-8 -*-
# お手軽速度計プラグイン。
# 速かったら自慢しましょう。ウザがられます

Module.new do
  plugin = Plugin.create :speedometer

  class << self
    attr_accessor :start_date

    def store
      @store ||= Hash.new{ |h, kind|
        h[kind] = Hash.new{ |j, idname| j[idname] = 0 } } end

    def refresh!
      @start_date = Time.new
      @store = nil end

    def speed(tph)
      "#{tph}tph (#{(tph.to_f / 3600 *100).to_i.to_f / 100}tps)" end

    def interval(now = Time.new)
      sum = 0
      sorted = store[:update].sort_by{ |pair| sum += pair[1]; -pair[1] }
      Plugin.call(:update, nil, [Message.new(:message =>
                                             "【TL流速】#{start_date}から1時間\n"+
                                             "#{speed(sum)}\n最もつぶやいた人\n"+
                                             sorted[0..2].to_enum(:each_with_index).map{ |n, i| "#{i+1}: @#{n[0]} #{speed(n[1])}" }.join("\n"),
                                             :system => true)])
      refresh!
    end

  end

  refresh!

  plugin.add_event(:update){ |service, messages|
    now = Time.new
    interval(now) if(3600 <= now - start_date)
    messages.each{ |message|
      store[:update][message.user.idname] += 1
    }
  }

end
