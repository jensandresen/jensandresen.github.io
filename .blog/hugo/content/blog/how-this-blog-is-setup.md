---
title: "How this blog is setup"
date: 2020-05-05
draft: true
---



I thought that the first real post in this blog could be about how the blog is actually set up. So let's have a peak under the hood.



## Background

I'm a fairly technical person and I'm pretty comfortable with the command line, git and writing markdown, so I wanted to go with an option that could support these. I have worked with a couple of CMS based solutions before and they are all really great (e.g. wordpress and the likes) and you can get up and running with just a couple of clicks. But I really like to version my work with git and writing markdown feels pretty simple, straight forward and a great fit for the blogging format - and I can bring my own editor!



## Simple choices

I've choosen the static site generator [Hugo](https://gohugo.io) for turning my markdown posts into html. I have no need - or a very modest need - for dynamics on the final website/blog, so this will do just fine. Once a blog post is written and published it is most likely never changed - so a static website is a great fit.

By going with a static website an easy choice for hosting is [GitHub](https://www.github.com) - this would by the way be a _two birds with one stone_ kind of choice because this would enable me to create a git repository to version control all the posts (and additional content) - perfect!

So now I have the basics in place - let's make it happen.



## Step 1 - hello world

So I wanted to setup a repository on GitHub and point my domain [jensandresen.com](https://www.jensandresen.com) to it. To do this I created a GitHub repository named according to their convention for hosting personal websites - in my case it was `jensandresen.github.io` which basically is `[your-username].github.io`. This enables you to browse the contents of the repository as a website and by visiting [http://jensandresen.github.io](http://jensandresen.github.io) in your browser. To verify that everything is working so far, I created a basic `index.htm`page in the root of the repository and pushed the commit to GitHub. After a couple of seconds (or maybe a minute) I was able to browse that page with my browser. Okay, it's verified - it works!



## Step 2 - set up Hugo

So I've decided to go with Hugo but I didn't want to install it on my system. Instead I wanted it to run inside a `Docker` container 