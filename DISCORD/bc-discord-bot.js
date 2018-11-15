// Usage: $0 <client secret>

const Discord = require("discord.js");
const client = new Discord.Client();

// TODO: read from file instead of providing on command line
client.login(process.argv[2]);

var channel, timer;

client.on("ready", () => {
    console.log("Starting...");
    // this is my single channel for right now
    channel = client.channels.get('509413318851559436');
    channel.send("I have been called into life at "+new Date());
    timer = setInterval(tellTime, 10000);
});

client.on("message", (message) => {
    if (message.content.startsWith("ping")) {
      message.channel.send("pong at "+ new Date());
    }
});

function tellTime () {channel.send("At the tone, "+new Date());}

function var_dump(obj) {
  var out = '';
  for (var i in obj) {
    out += i + ": " + obj[i] + "\n";
  }

  return out;
}
