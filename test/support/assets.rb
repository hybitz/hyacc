# coding: UTF-8

def valid_asset_params
  {
    :name => '資産' + time_string,
  }
end

def invalid_asset_params
  {
    :name => '',
  }
end

def asset
  @_asset_cache ||= Asset.first
end
