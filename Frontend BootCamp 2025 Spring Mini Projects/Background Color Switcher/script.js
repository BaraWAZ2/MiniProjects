const body = document.getElementById("body");
const title = document.getElementById("title");

function red() {
    body.style.backgroundColor = "red";
    title.style.color = "white";
    localStorage.setItem("background", "red");
    localStorage.setItem("text", "white");
}
function green() {
    body.style.backgroundColor = "green";
    title.style.color = "white";
    localStorage.setItem("background", "green");
    localStorage.setItem("text", "white");
}
function blue() {
    body.style.backgroundColor = "blue";
    title.style.color = "white";
    localStorage.setItem("background", "blue");
    localStorage.setItem("text", "white");
}

const buttonArray = document.getElementsByClassName("button");
for (let button of buttonArray) {
    button.addEventListener("mouseover", () => {
        button.style.color = "rgb(211, 211, 211)";
    });
    button.addEventListener("mouseout", () => {
        button.style.color = "white";
    });
};

window.addEventListener("load", () => {
    const backgroundColor = localStorage.getItem("background");
    if (backgroundColor) {
        body.style.backgroundColor = backgroundColor;
        title.style.color = localStorage.getItem("text");
    }
});

console.log(localStorage);