// Usage: $0 <client secret>

// Do I need both hook and login?
var hookid = process.argv[3];
var hooktoken = process.argv[4];

const Discord = require("discord.js");
const client = new Discord.Client();
// const hook = new Discord.WebhookClient(hookid, hooktoken);

// TODO: read from file instead of providing on command line
client.login(process.argv[2]);

client.on("ready", () => {
    console.log("I am ready!");
    console.log(client.guilds);
    console.log(client.channels);
});

// hook.send("Shiver me timers, matey");

// client.send_message("I am alive!");

client.on("message", (message) => {
    if (message.content.startsWith("ping")) {
      message.channel.send("pong!");
    }
  });

