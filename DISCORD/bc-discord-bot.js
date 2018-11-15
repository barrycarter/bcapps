const Discord = require("discord.js");
const client = new Discord.Client();

// TODO: read from file instead of providing on command line

client.login(process.argv[2]);

client.on("message", (message) => {
    if (message.content.startsWith("ping")) {
      message.channel.send("pong!");
    }
  });

