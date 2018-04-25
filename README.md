# Project3_wdi

Ever encountering the difficulty of having to switch between multiple tabs to compare prices when buying things online? Well we have a solution for you right here! This app works similarly to trivago in such a way that it consolidates and find the best prices from various ecommerce platforms and display the results to you. With this, you will be able to compare the best prices from the various platforms in a single page.

## Getting Started

The instructions below will get you a copy of the project up and running on your local machine for development and testing purposes. See deployment section for notes on how to deploy the project on a live system.

### Prerequisites

Make sure to download/install the following items:
* Text Editor - Up to your own preference, I personally prefer atom (https://atom.io/)
* Ubuntu Terminal(For Windows User) - Search for ubuntu in Microsoft store
* Ruby - https://gorails.com/setup/windows/10
* Rails - https://gorails.com/setup/windows/10
* PostgreSQL - https://www.postgresql.org/download/
* Heroku CLI - https://devcenter.heroku.com/articles/heroku-cli
* Git - https://git-scm.com/

Do remember to check that the environment variables are updated after installing the above items

### Installation

Once you are done with the prerequisites, let's move on to the installation. Note that the next few steps are meant for localhost development only.

**Step 1** => Clone the project into a folder on your local machine

**Step 2** => Open ubuntu terminal and cd into the cloned project folder

**Step 3** => Type this command to install the gems specified in the rails app
```
bundle install
```

**Step 4** => Type this command to create a database in postgresQL
```
FOR WINDOWS USER
CREATE DATABASE <database name specified in database.yml under config folder> using the psql shell
```
```
FOR MAC USERS
rails db:create
```

**Step 5** => Type this command to create the tables in the database
```
rails db:migrate
```

**Step 6** => Type this command to start the rails server
```
rails s
```

**Step 7** => Open your browser and enter this url into the address bar
```
localhost:3000
```

## Wireframes

The following below shows the wireframes I came up with during the planning process.
![alt text]()


## ERD Diagrams

The following shows the relationships between the various database tables for this project.
![alt text](https://i.imgur.com/fjMiDrg.jpg)

## User Stories
Click this link to view the user stories for this project - https://trello.com/b/wqxejIl0/web-crawler

## Built With
**Frameworks**
* [Ruby On Rails](http://rubyonrails.org/) - A server-side web application framework written in Ruby
* [MDBootstrap](https://mdbootstrap.com/) - The front-end framework used that aligns with Google Material Design

**GEM Packages**
* [Mechanize](https://rubygems.org/gems/mechanize/versions/2.7.5) - Used to handle the crawling of data from Lazada

**Database**
* [PostgreSQL](https://www.postgresql.org/) - Open Source Database
