#
# Cookbook Name:: gnupg
# Provider:: key
#
# Copyright 2012, cj Advertising, LLC.
#
# Permission is hereby granted, free of charge, to any person obtaining
# a copy of this software and associated documentation files (the
# "Software"), to deal in the Software without restriction, including
# without limitation the rights to use, copy, modify, merge, publish,
# distribute, sublicense, and/or sell copies of the Software, and to
# permit persons to whom the Software is furnished to do so, subject to
# the following conditions:
#
# The above copyright notice and this permission notice shall be
# included in all copies or substantial portions of the Software.
#
# THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND,
# EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF
# MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND
# NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE
# LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION
# OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION
# WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
#

action :install do

  tmp_path = "/tmp/gnupg-tmp-#{new_resource.key_id}"
  
  file "gnupg-rm-tmp-key-#{new_resource.name}" do
    path tmp_path
    action :nothing
  end
  
  execute "gnupg-install-key-#{new_resource.name}" do
    command "gpg --homedir=~#{new_resource.user}/.gnupg --import #{tmp_path}"
    user new_resource.user
    action :nothing
    notifies :delete, resources(:file => "gnupg-rm-tmp-key-#{new_resource.name}"), :immediately
  end
  
  file "gnupg-tmp-key-#{new_resource.name}" do
    path tmp_path
    content new_resource.key
    mode "0600"
    owner new_resource.user
    
    action :create
    not_if "gpg --homedir=~#{new_resource.user}/.gnupg --list-#{'secret-' if new_resource.secret}keys | grep #{new_resource.key_id}", :user => new_resource.user
    notifies :run, resources(:execute => "gnupg-install-key-#{new_resource.name}"), :immediately
  end
end