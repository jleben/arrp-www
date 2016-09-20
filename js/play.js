
window.onload = function() {
  populateExampleList();
  selectExample();
};

var examples = {
triangle:
`\
phase = [i -> (i % 10) / 10];

triangle = 1 - abs(2 * phase - 1);

main = triangle`,
osc:
`\
## Supports variable frequency

phase(freq) = p = [
    0 -> 0;
    t -> let x = p[t-1] + freq[t] in
      if x < 1 then x else x - 1
];

osc(freq) = sin(phase(freq) * 2 * pi)
  where pi = atan(1) * 4;

main = osc(0.1); ## Constant frequency
## main = osc([t -> 0.1 + t/1000]); ## Or variable frequency
`,
windows:
`\
windows(size, hop, x) = [t -> [size: i -> x[t*hop + i]]];

signal = [t -> t];

main = windows(4,2,signal);
`,
arg_max:
`\
arg_max(x) = y[#y-1,1]
    where y = [
        0 -> [x[0]; 0];
        i -> if x[i] > y[i-1,0]
             then [x[i]; i]
             else y[i-1]
    ];

main = arg_max([3;0;5;9;4;2]);
`,
lp:
`\
delay(v,a) = [0 -> v; t -> a[t-1]];

lp(a,x) =
  y = a*x + (1-a)*delay(0,y);

## Test signal: 3 harmonics
signal = [t -> [3:i -> sin(f(i)*t*2*pi)]]
   where { pi = atan(1)*4; f(i) = (2*i+1)*0.01; };

main = lp(0.1, signal);
`
};

function populateExampleList() {
  list = document.getElementById("example-selection");
  function addExample(value, name) {
    option = document.createElement('option');
    option.value = value;
    text = document.createTextNode(name);
    option.appendChild(text);
    list.appendChild(option);
  }
  addExample('triangle', 'Triangle Wave');
  addExample('osc', 'Variable-Frequency Oscillator');
  addExample('lp', 'Recursive Low-pass Filter');
  addExample('windows', 'Sliding Windows');
  addExample('arg_max', 'Arg Max');
}

function selectExample() {
  var key = document.getElementById("example-selection").value;
  var code = examples[key];
  //console.log("selected example = " + key);
  document.getElementById("arrp-input").value = code;
}

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
