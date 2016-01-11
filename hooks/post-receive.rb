#!/usr/bin/env ruby

# Aside from removing Ruby on Rails specific code this is taken verbatim from
# mislav's git-deploy (http://github.com/mislav/git-deploy) and it's awesome
#  - Ryan Florence (http://ryanflorence.com)
#
# Install this hook to a remote repository with a working tree, when you push
# to it, this hook will reset the head so the files are updated

if ENV['GIT_DIR'] == '.'
  # this means the script has been called as a hook, not manually.
  # get the proper GIT_DIR so we can descend into the working copy dir;
  # if we don't then `git reset --hard` doesn't affect the working tree.
  Dir.chdir('..')
  ENV['GIT_DIR'] = '.git'
end

cmd = %(bash -c "[ -f /etc/profile ] && source /etc/profile; echo $PATH")
envpath = IO.popen(cmd, 'r') { |io| io.read.chomp }
ENV['PATH'] = envpath

# find out the current branch
head = `git symbolic-ref HEAD`.chomp
# abort if we're on a detached head
exit unless $?.success?

oldrev = newrev = nil
null_ref = '0' * 40

# read the STDIN to detect if this push changed the current branch
while newrev.nil? and gets
  # each line of input is in form of "<oldrev> <newrev> <refname>"
  revs = $_.split
  oldrev, newrev = revs if head == revs.pop
end

# abort if there's no update, or in case the branch is deleted
exit if newrev.nil? or newrev == null_ref

# update the working copy
`umask 002 && git reset --hard`

# now find the deployment script and execute it
git_dir = ENV['GIT_DIR']
deploy_scripts = ['deploy.sh', 'config/deploy.sh']
deploy_hook_name = 'deploy'

# find the deployment script and copy it to the hooks dir
deploy_scripts.each do |file|
  path = "#{git_dir}/../#{file}"

  if File.exists? path
    `cp #{path} #{git_dir}/hooks/#{deploy_hook_name}`
    `chmod 711 #{git_dir}/hooks/#{deploy_hook_name}`
    break
  end
end

# execute the deployment hook, if it exists 
if File.exists? "#{git_dir}/hooks/#{deploy_hook_name}"
  system "#{git_dir}/hooks/#{deploy_hook_name}"
end
