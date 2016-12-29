# netmuxer
This opens a server on localhost port 4501

Send messages in the form  
`<ip>,<port>,<message>\n`  
and the message will be relayed to that host and port

Keep the connection open, and responses will arrive and be relayed back in the form  
`<ip>,<port>,<message>\n`  
meaning that the message came from that host and port

A list of relay targets will be shown in the Processing display window  
Incoming and outgoing messages will scroll by in the Processing console  
Target connections and disconnections will be logged to a file in the processing sketch folder
