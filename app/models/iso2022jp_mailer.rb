# -*- encoding : utf-8 -*-
#
# $Id: iso2022jp_mailer.rb 2471 2011-03-23 14:59:36Z ichy $
# Product: hyacc
# Copyright 2009 by Hybitz.co.ltd
# ALL Rights Reserved.
#
require 'nkf'

class Iso2022jpMailer < ActionMailer::Base
  @@default_charset = 'iso-2022-jp'  # これがないと "Content-Type: charset=utf-8" になる
  @@encode_subject  = false          # デフォルトのエンコード処理は行わない(自分でやる)

  # 1) base64 の符号化 (http://wiki.fdiary.net/rails/?ActionMailer より)
  def base64(text, charset="iso-2022-jp", convert=true)
    if convert
      if charset == "iso-2022-jp"
        text = NKF.nkf('-j -m0', text)
      end
    end
    text = [text].pack('m').delete("\r\n")
    "=?#{charset}?B?#{text}?="
  end

  # 2) 本文を iso-2022-jp へ変換
  # どこでやればいいのか迷ったので、とりあえず create! に被せています
  def create! (*)
    super
    @mail.body = NKF::nkf('-j', @mail.body)
    return @mail   # メソッドチェインを期待した変更があったら怖いので
  end

end
