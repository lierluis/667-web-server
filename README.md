# CSC 667 Web Server Project

I'm currently writing the project so it's in a constant state of change.  The master branch 
contains the skeleton and a failing test suite against that skeleton (in as much as I have 
specified them to this point). The goal is for you guinea pigs to play with the project and 
see what you can get done, where it's lacking, etc.

The project is executed on jruby instead of Ruby MRI that we used in class, so you'll need 
to set up your environment to be able to do that (using RBenv or RVM - there's a .rvmrc file 
in the repo, so if you have RVM installed, you should be good to go).

## Getting Started

Once your copy of the repo has been created, install the gems specified
in the gem file via bundler:
```
bundle install
```

To run the entire test suite:
```
rspec
```

To run the web server (nothing will happen until you implement...):
```
ruby web_server.rb
```

## Creating Branches

Forget a command? Try
```
git help
```

Create a named branch, typically named after the feature you are working
on.
```
git branch request
```

Switch to the branch in order to begin your work.
```
git checkout request
```

Let GitHub know you would like to have a remote branch that mirrors the
work you have done in the local branch.
```
git push --set-upstream origin request
```

## Managing Your Branches

To see the status of your current branch:
```
git status
```

In order to make sure that you have the most recent copy of the origin
(the copy on Github), you pull:
```
git pull
```

In order to add *ALL* changes into your current branch:
```
git add . 
```
In order to add a specific file into your current branch:
```
git add filename
```

In order to commit *ALL* (-a) your changes, with a commit message (-m):
```
git commit -am "The commit message"
```
