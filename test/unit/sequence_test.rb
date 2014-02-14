# -*- encoding : utf-8 -*-
#
# $Id: sequence_test.rb 2484 2011-03-23 15:51:29Z ichy $
# Product: hyacc
# Copyright 2009 by Hybitz.co.ltd
# ALL Rights Reserved.
#
require 'test_helper'

class SequenceTest < ActiveRecord::TestCase

  def test_create_sequence
    assert_nothing_raised{
      Sequence.create_sequence("test")
    }
  end
  
  def test_next_value
    assert_equal 2, Sequence.next_value("Asset", "2009")
  end
end
