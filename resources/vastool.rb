# A resource for manipulating vastool

actions :join
default_action :join

attribute :name, kind_of: String, name_attribute: true
attribute :user, kind_of: String, default: nil
attribute :pass, kind_of: String, default: nil
attribute :baseou, kind_of: String, default: nil
attribute :domain, kind_of: String, default: nil
attribute :fqdn, kind_of: String, default: nil
attribute :force, kind_of: [TrueClass, FalseClass], default: false

provides :vastool
