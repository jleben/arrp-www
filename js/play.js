
function sendArrpInput(post_url) {

  var text = document.getElementById("arrp-input").value;

  var data = new Blob([text], {type: 'text/plain'});

  var out_count = document.getElementById("out-count").value;

  var xmlhttp = new XMLHttpRequest();

  console.log("Posting...\n");

  xmlhttp.onreadystatechange = function() {
      console.log("State change: " + xmlhttp.readyState);
      if (xmlhttp.readyState != 4) {
          return;
      }
      if (xmlhttp.status != 200) {
          var msg = "An error occured with the network request.\n"
                  + "HTTP status = " + xmlhttp.status + ".\n";
                  + xmlhttp.responseText;
          document.getElementById("arrp-output").value = msg;
      }
      else {
          processArrpResponse(xmlhttp.responseText);
      }
  };
  xmlhttp.open("POST", post_url + "?out_count=" + out_count, true);
  xmlhttp.send(data);
  document.getElementById("arrp-output").value = "Waiting for response...";
}

function processArrpResponse(text) {
    console.log("Reponse:\n" + text);
    document.getElementById("arrp-output").value = text;
}