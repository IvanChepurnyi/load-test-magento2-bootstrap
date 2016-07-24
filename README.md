# Magento 2.x Instance Bootstrap for load test

Bootstrap for load testing


## Setup

It is designed for byte hypernode instance, if you have a different setup it might not work. 

You can try it out on your local machine by using the following vagrant box:
https://github.com/EcomDev/fast-hypernode

## Installation

1. Clone repository on hypernode instance
2. Run `setup.sh` with desired database name, domain and Magento version
3. Before running each load test cycle run `prepare.sh` with database name as an argument


