# CarrierLink

CarrierLink is a routing engine for Yate (http://www.null.ro/yate.php).
It was written mainly in 2014 and uses the async/await task model to be as non-blocking as possible.

# How does it work?
CarrierLink connects to Yate via TCP and receives information about incoming calls (and other events) and finds the best route for a call. It then sends back routing information to Yate, so that Yate can route the VoIP call. It uses a PostgreSQL database as backend that holds customer, gateway, price, and other information and caches a lot of information locally to speed up routing. CarrierLink also does billing and simple load balancing.
CarrierLink unfortunately does not have a web interface which I am able to publish. Thus, it is difficult to manage all the configuration that resides in the database. In case someone is interested, feel free to get in touch with me.

## Web Frontend
Unfortunately I cannot publish a web frontend for CarrierLink.

## Technologies
- .NET Core 2.1 (originally written in .NET Framework 4.5, ported to .NET Core in 2017)
- Entity Framework
- Npgsql
- NLog

## Yate Simulator
In order to test CarrierLink, I also wrote a Yate simulator, which generates messages to feed CarrierLink.

## Performance
On an old AMD Phenom II X4 processor that I used in 2015 CarrierLink could easily handle 300 routing request per second (calls per second).
Average routing time was less than 5ms.

## Database
The database could easily grow a couple hundred megabytes per day and for the Call Data Records a new inherited table was automatically created every week to increase performance and simplify deletion of data by simply dropping the table.
Nowadays, usage of TimescaleDB (which was developed around the same time as CarrierLink) probably can bring additional performance advantages.

## Components
The following projects compose the main functionality.

### Engine
This project contains the routing engine as library. It is used in project 'Daemon' to run as a daemon and 'Yate' to connect to a Yate server. Several engines can be connected to the same Yate server for simple load balancing. In case load is too high in one Engine then messages are returned unhandled so that subsequently registered Engines would receive the unhandled messages and process them.
The Engine also has a simple REST Api that can be queried to retrieve live statistics.

### Yate
This project does the connection handling to Yate and the low level communication with the TCP socket. This library could also be used independently in other projects to connect to Yate.

### Yate.Scripts
This project contains two php scripts that can be loaded into Yate in order to receive load information in the Engine. The Engine uses this information to return messages when the load is too high in Yate so that Yate rejects taking the call.