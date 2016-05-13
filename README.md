qas Cookbook
========================
Rudimentary implementation of QAS - configures a directory services client with Quest Authentication Service

Requirements
------------ 
#### packages
- `ntp` - NTP is necessary to maintain kerberos ticket validity
- 'vasd-selinux' - files are included from the https://github.com/dell-oss/vasd-selinux.git repository

Usage
-----
Include `qas` in your node's `run_list`:

```json
{
  "name":"my_node",
  "run_list": [
    "recipe[qas]"
  ]
}
```

An example of calling the provider:

```ruby
vastool 'join' do
  user 'provisioning_user'
  pass 'P4ssword!'
  baseou 'OU=Servers,DC=example,DC=com'
  domain 'example.com'
  fqdn node['fqdn']
  action :join
  notifies :restart, 'service[sshd]', :immediately
  notifies :restart, 'service[vasd]', :immediately
end
```

Optionally, setting node['qas']['configure_kerberos'] to true will instruct the resource to configure Kerberos for single sign-on


Contributing
------------
1. Fork the repository on Github
2. Create a named feature branch (like `add_component_x`)
3. Write your change
4. Write tests for your change (if applicable)
5. Run the tests, ensuring they all pass
6. Submit a Pull Request using Github

