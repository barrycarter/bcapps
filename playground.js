<html><head></head><body><script language="PerlScript">
$window->document->write('This comes from perl\n');
</script>

<!--


/* XMLHTTPREQUEST testing or something */

<script type="text/javascript">

x = new XMLHttpdRequest();
x.open('GET', 'http://test.barrycarter.info/playground.pl');
x.send();
x.onreadystatechange = handler;

function handler {
  if(x.readyState == 4 && x.status == 200) {
    rt = x.responseText;
    rt.split(",");
    alert("RT: rt[0] and rt[1]");
  }

  sleep(1);
}

</script>

<div id="test">hello there</div>

<script type="text/javascript">

test.color = '#ff0000';

</script>

-->
