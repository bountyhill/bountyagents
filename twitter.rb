# Some twitter experiments
Twitter.configure(twitter_config)

user = Twitter.user("Bukowsky") #.object_id 
follower_ids = Twitter.follower_ids("Bukowsky").all
W "got #{cursor.all.length} followers"

ap next_cursor = cursor.next_cursor
W "next_cursor", next_cursor

cursor = Twitter.follower_ids("Bukowsky", :cursor => next_cursor)
W "got #{cursor.length} followers"

ap next_cursor = cursor.next_cursor
W "next_cursor", next_cursor

cursor = Twitter.follower_ids("Bukowsky", :cursor => next_cursor)
W "got #{cursor.length} followers"

