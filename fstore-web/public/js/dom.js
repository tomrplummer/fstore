// Function to determine the type of an object
var type = function (o) {
  return Object.prototype.toString
    .call(o)
    .replace("[object ", "")
    .replace("]", "");
};

// Object to store HTML element creation functions
let h = {};

// Function to append an HTML element to another element or the document body
h["append"] = function (html, element) {
  element = document.getElementById(element) || document.body;
  element.appendChild(html);
};

// Function to prepend an HTML element to another element or the document body
h["prepend"] = function (html, element) {
  element = document.getElementById(element) || document.body;
  var children = [];
  for (var i = 0; i < element.children.length; i++) {
    children.push(element.children[i]);
  }
  element.appendChild(html);
  for (var i = 0; i < children.length; i++) {
    element.appendChild(children[i]);
  }
};

// Function to create a singleton HTML element
var singletonBuilder = function (tag) {
  return function (obj) {
    var element = document.createElement(tag);
    var attr;
    if (obj) {
      for (var i in obj) {
        attr = i.replace("_", ""); // .replace("class", "className");
        if (!/^(data|on|selected|inner|checked)/.test(attr)) {
          element.setAttribute(attr, obj[i]);
        } else if (attr == "text") {
          element.setAttribute("innerText", obj[i]);
        } else if (attr == "html") {
          element.setAttribute("innerHTML", obj[i]);
        } else if (/checked/.test(attr)) {
          if (obj[i] == "true" || obj[i] == true) {
            element[attr] = obj[i];
          }
        } else {
          element[attr] = obj[i];
        }
      }
    }
    return element;
  };
};

// Function to create an HTML element with children
var elementBuilder = function (tag) {
  return function () {
    var args = arguments,
      obj,
      ary,
      element,
      val;
    element = document.createElement(tag);
    for (var i = 0; i < args.length; i++) {
      switch (type(args[i])) {
        case "Object":
          obj = args[i];
          break;
        case "Array":
          ary = args[i];
          break;
        default:
          val = args[i];
          break;
      }
    }
    if (obj) {
      for (var i in obj) {
        var attr;
        attr = i.replace("_", ""); // .replace("class", "className");
        if (attr.toLowerCase() == "class") {
          if (type(obj[i]) == "Array") {
            obj[i] = obj[i].join(" ");
          }
        }
        if (!/^(on|selected|inner|checked|disabled)/.test(attr)) {
          element.setAttribute(attr, obj[i]);
        } else if (attr == "text") {
          element.setAttribute("innerText", obj[i]);
        } else if (attr == "html") {
          element.setAttribute("innerHTML", obj[i]);
        } else {
          element[attr] = obj[i];
        }
      }
    }
    if (ary) {
      for (var i = 0; i < ary.length; i++) {
        if (type(ary[i]) == "String") {
          element.appendChild(TEXT(ary[i]));
        } else {
          element.appendChild(ary[i]);
        }
      }
    } else {
      if (val) {
        element.innerText = val;
      }
    }
    return element;
  };
};

// Define HTML element creation functions
h["h1"] = elementBuilder("h1");
h["h2"] = elementBuilder("h2");
h["h3"] = elementBuilder("h3");
h["h4"] = elementBuilder("h4");
h["h5"] = elementBuilder("h5");
h["h6"] = elementBuilder("h6");
h["i"] = elementBuilder("i");
h["label"] = elementBuilder("label");
h["span"] = elementBuilder("span");
h["a"] = elementBuilder("a");
h["button"] = elementBuilder("button");
h["p"] = elementBuilder("p");
h["quote"] = elementBuilder("quote");
h["td"] = elementBuilder("td");
h["th"] = elementBuilder("th");
h["li"] = elementBuilder("LI");
h["option"] = elementBuilder("option");
h["text"] = elementBuilder("text");
h["input"] = singletonBuilder("input");
h["img"] = singletonBuilder("img");
h["textarea"] = singletonBuilder("textarea");
h["div"] = elementBuilder("div");
h["section"] = elementBuilder("section");
h["header"] = elementBuilder("header");
h["footer"] = elementBuilder("footer");
h["article"] = elementBuilder("article");
h["table"] = elementBuilder("table");
h["thead"] = elementBuilder("thead");
h["tr"] = elementBuilder("tr");
h["ul"] = elementBuilder("ul");
h["ol"] = elementBuilder("ol");
h["select"] = elementBuilder("select");
h["tbody"] = elementBuilder("tbody");
h["form"] = elementBuilder("form");
