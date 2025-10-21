//  part 1 with Majd 

// The first example to understand the Dom
const helloDiv = document.getElementById("hello");
helloDiv.innerText = "Hello from JS";
helloDiv.innerHTML = "<h1> Hello from JS </h1>";


// The second example --> DOM Methods and Attribute Manipulation
// 1. getElementById
const title = document.getElementById("main-title");
title.textContent = "My title from JS";
title.style.color = "red";
title.style.fontSize = "30px";

// 2. getElementsByClassName
const items = document.getElementsByClassName("item");
for (let i = 0; i < items.length; i++) {
    items[i].style.border = "2px dashed blue";
}

// 3. querySelector
const para = document.querySelector(".text");
para.style.backgroundColor = "yellow";

// 4. querySelectorAll
const allItems = document.querySelectorAll(".item");


// The third example --> Using classList with add, remove, and toggle
const boxElm = document.getElementById("box");
boxElm.classList.add("box"); 

function toggle() {
  boxElm.classList.toggle("bg"); 
};
// boxElm.classList.remove("active-btn");


// The fourth example --> Creating and Manipulating DOM Elements: Append, Prepend, Insert, and Remove
const container = document.getElementById("container");

const div1 = document.createElement("div");
div1.textContent = "Appended using appendChild";
div1.style.backgroundColor = "lightblue";
div1.style.padding = "10px";
div1.style.margin = "5px 0";

container.appendChild(div1);

const h2 = document.createElement("h2");
h2.textContent = "Appended using append";
h2.style.cssText = "background-color: lightgreen; padding: 10px; margin: 5px 0;";
h2.id = "appendedDiv";

container.append(h2);

const div3 = document.createElement("div");
div3.textContent = "Prepended at the top";
div3.style.border = "1px solid black";
div3.style.padding = "10px";

container.prepend(div3);

const div4 = document.createElement("div");
div4.textContent = "Inserted using insertAdjacentElement";
div4.style.fontWeight = "bold";
div4.style.padding = "10px";
div4.style.margin = "5px 0";
div4.style.backgroundColor = "#eee";

container.insertAdjacentElement("beforeend", div4);

h2.remove();




//  part 2 with Rand 

const btn = document.getElementById("btn");
const input = document.getElementById("yourName");
const vehicles = document.querySelectorAll("#vehicle");
const p = document.getElementById("output");
const p2 = document.getElementById("output2");
const t = document.getElementById("title")

//Click Event
btn.addEventListener("click", function MtFunc() {
    alert(`Welcome ${input.value}`)
});
//--------------------------------
//mouseover & mouseout Events
function MtFunc2() {
    btn.style.background = "orange";
}

function MtFunc3() {
    btn.style.background = "black";
    btn.style.color = "white"
}
btn.addEventListener("mouseover", MtFunc2);
btn.addEventListener("mouseout", MtFunc3);

//--------------------------------
//Change Event & Another example to use a localStorge
vehicles.forEach(vehicle => {
    // Load stored state
    const isChecked = localStorage.getItem(vehicle.value);
    if (isChecked === "true") {
        vehicle.checked = true;
    }
    // Store state on change
    vehicle.addEventListener("change", function MyFunc4() {
        p.innerText = `The Select is: ${vehicle.value}`;
        localStorage.setItem(vehicle.value, vehicle.checked);
        localStorage.setItem("selected", vehicle.value);
    });
});

//--------------------------------
//keydown Event
input.addEventListener("keydown", (e) => {
    localStorage.setItem("char", e.key);
    p2.innerText = `The Key is: ${e.key}`;
});

//💡 What is the event object?
//The event object is automatically passed to event handler functions.
//It gives you information about the event that happened (like a click, key press, input, etc.).
//(event.type)=> tells the event type, (event.target)=> gives the affected element, (event.key)=> shows the pressed key, and (event.preventDefault())=> stops the default browser action.

//--------------------------------
//(Window Events) resize Event
function getRandomColor() {
    const r = Math.floor(Math.random() * 256);
    const g = Math.floor(Math.random() * 256);
    const b = Math.floor(Math.random() * 256);
    return `rgb(${r}, ${g}, ${b})`;
};

window.addEventListener("resize", () => {

    t.style.background = getRandomColor();
});

//--------------------------------
//(Window Events) load Event
window.addEventListener("load", () => {
    const char = localStorage.getItem("char");
    const selected = localStorage.getItem("selected");
    if (selected) {
        p.innerText = `The Select is: ${selected}`;
    }
    if (char) {
        p2.innerText = `The Key is: ${char}`;
    }

});
//------------------------------------------------------------------
// localStorge
//💡 What is localStorage?
// localStorage is a web storage API that allows you to store data in the browser, and the data persists even after the page is closed or refreshed.
// => It only stores data as strings, so objects/arrays must be converted using JSON.stringify() and JSON.parse().

//localStorge Methods =>
//1)setItem(key, value)
//2)getItem(key)
//3)removeItem(key)
//4)clear() 

// 1. setItem(key, value)=> Stores data in localStorage.
localStorage.setItem("username", "Hala");
//With an object:
const user = { name: "Ahmad", age: 20 };
localStorage.setItem("user", JSON.stringify(user));

//2. getItem(key)=> Retrieves stored data.
const name = localStorage.getItem("username"); // "Hala"
//With an object:

const user2 = JSON.parse(localStorage.getItem("user"));
console.log(user2.name); // "Ahmad"

// 3. removeItem(key)=> Removes a specific key/value from storage.
localStorage.removeItem("username");

// 4. clear()=> Clears all localStorage data.
// localStorage.clear();