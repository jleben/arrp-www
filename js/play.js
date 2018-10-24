
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
phase(freq) = p where {
  p :: [~]real64;
  p = [
    0 -> 0;
    t -> let x = p[t-1] + freq[t] in
         if x < 1 then x else x - 1
  ];
};

osc(freq) = sin(phase(freq) * 2 * pi)
  where pi = atan(1) * 4;

## Using variable frequency:
main = osc([t -> 0.1 + t/1000]);

## But constant frequency works as well:
## main = osc(0.1);
`,
wavetable_osc:
`\
pi = 4*atan(1);

table_size = 20;
table = [table_size: i -> sin(i/table_size*2*pi)];

interpolate(a,i) =
  let d = i - floor(i) in
  a[int(i) % #a] * (1-d) + a[(int(i)+1) % #a] * d;

osc(table, freq) =
  [~: t -> interpolate(table, t * freq  * #table)];

precise_osc(freq) =
  [~: t -> sin(t*freq*2*pi)];

freq = 1/9;

## Compare wavetable vs. precise:
main = [osc(table, freq); precise_osc(freq)];
`,
windows:
`\
windows(size, hop, x) = [t -> [size: i -> x[t*hop + i]]];

signal = [t -> t];

main = windows(4,2,signal);
`,
arg_max:
`\
arg_max(x) = y[#y-1,1] where {
    y :: [#x,2]int;
    y = [
        0 -> [x[0]; 0];
        i -> if x[i] > y[i-1,0]
             then [x[i]; i]
             else y[i-1]
    ];
};

main = arg_max([3;0;5;9;4;2]);
`,
lp:
`\
delay(v,a) = [0 -> v; t -> a[t-1]];

lp(a,x) = y where {
  y :: [~]real64;
  y = a*x + (1-a)*delay(0,y);
};

## Test signal
osc(f) = [t -> sin(f*t*2*pi)] where { pi = atan(1)*4; };

main = [3: i -> lp(0.1, osc((2*i+1)*0.01))];
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
  addExample('triangle', 'Triangle wave');
  addExample('osc', 'Variable-frequency oscillator');
  addExample('wavetable_osc', 'Wavetable oscillator');
  addExample('lp', 'Recursive low-pass filter');
  addExample('windows', 'Sliding windows');
  addExample('arg_max', 'Arg-max');
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
