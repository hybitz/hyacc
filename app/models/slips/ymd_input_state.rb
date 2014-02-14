# -*- encoding : utf-8 -*-
#
# $Id: ymd_input_state.rb 2478 2011-03-23 15:29:50Z ichy $
# Product: hyacc
# Copyright 2009 by Hybitz.co.ltd
# ALL Rights Reserved.
#
module Slips
  # 簡易入力の年月日の入力状態を保持するクラス
  class YmdInputState
    attr_accessor :ym
    attr_accessor :day
  end
end
