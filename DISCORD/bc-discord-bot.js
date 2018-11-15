// Usage: $0 <client secret>

// Do I need both hook and login?
var hookid = process.argv[3];
var hooktoken = process.argv[4];

const Discord = require("discord.js");
const client = new Discord.Client();
// const hook = new Discord.WebhookClient(hookid, hooktoken);

// TODO: read from file instead of providing on command line
client.login(process.argv[2]);

var channel, channels;

client.on("ready", () => {
    console.log("I am ready!");
    channels = client.channels;
    // this is a one-channel bot for now
    channel = channels.get('509413318851559436');
    channel.send("I have been summoned!");
    console.log(channel);
    //    console.log(channels('509413318851559435'));
    //    console.log("start");
    //    for (var [key, val] of channels) {console.log(""+key+", "+var_dump(val));}
    //    console.log("end");
});

// hook.send("Shiver me timers, matey");

// client.send_message("I am alive!");

client.on("message", (message) => {
    if (message.content.startsWith("ping")) {
      message.channel.send("pong!");
      message.channel.send(channels);
    }
});

function var_dump(obj) {
  var out = '';
  for (var i in obj) {
    out += i + ": " + obj[i] + "\n";
  }

  return out;
}
