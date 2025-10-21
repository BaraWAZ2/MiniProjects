const gallery = document.getElementById("gallery");
const attachers = gallery.getElementsByTagName("button");
Array.from(attachers).forEach((b) => attachFunction(b));

const container = document.getElementById("current-inventory");

const clone = document.getElementById("clone").cloneNode(true);
clone.removeAttribute("id");
clone.style.display = "flex";

const buttons = document.getElementsByTagName("button");
Array.from(buttons).forEach((b) => hoverEffect(b));

const plus = container.getElementsByClassName("plus");
const minus = container.getElementsByClassName("minus");

const clear = document.getElementById("clear");
const proceed = document.getElementById("checkout");
clear.addEventListener("click", (e) => clearAll(false));
proceed.addEventListener("click", (e) => clearAll(true));

const itemsCount = document.getElementById("items-count");
const total = document.getElementById("total");

const searchbar = document.getElementById("search-bar");
searchbar.addEventListener("input", (e) => filter(searchbar.value));

const cart = document.getElementById("cart");
const darkMode = document.getElementById("dark-mode");

cart.addEventListener("click", (e) => tellTotal());

darkMode.addEventListener("click", (e) => toggleDarkMode());

let isDarkMode = false;
function toggleDarkMode() {
    if (isDarkMode)
        document.body.classList.remove("dark-mode");
    else 
        document.body.classList.add("dark-mode");
    isDarkMode = !isDarkMode;
    localStorage.setItem("darkmode", isDarkMode);
}

function filter(text) {
    console.log("victory!!!!", text)
    if (text === "") {
        Array.from(gallery.children).forEach((p) => {
            p.style.display = "flex";
        });
        return;
    }
    console.log(gallery.children);
    Array.from(gallery.children).forEach((p) => {
        const productName = p.querySelector(".product-name");
        console.log(p);
        console.log(productName);
        console.log(productName.innerHTML);
        if (productName.innerHTML.toLocaleLowerCase().includes(text.toLocaleLowerCase()))
            p.style.display = "flex";
        else 
            p.style.display = "none";
    });
}

function hoverEffect(buttonReference) {
    buttonReference.addEventListener("mouseover", (e) => {
        buttonReference.style.filter = "brightness(.93)";
    });
    
    buttonReference.addEventListener("mouseout", (e) => {
        buttonReference.style.filter = "brightness(1)";
    });
}

function attachFunction(buttonReference) {
    buttonReference.addEventListener("click", (e) => {
        
        const emptyMessage = container.querySelector("p");
        if (emptyMessage !== null) {
            emptyMessage.style.display = "none";
        }

        const parent = e.target.parentElement;
        const price = parent.querySelector(".price");

        itemsCount.innerHTML = (parseInt(itemsCount.innerHTML) + 1).toString();
        total.innerHTML = (parseFloat(total.innerHTML) + parseFloat(price.innerHTML)).toFixed(2).toString();
        
        const possibleMatch = container.querySelector("#" + parent.id + "-clone");
        if (possibleMatch !== null) {
            const description = possibleMatch.children[1];
            const count = description.children[1].children[1];
            count.innerHTML = (parseInt(count.innerHTML) + 1).toString();
            localStorage.setItem(`${possibleMatch.id}`, `${count.innerHTML}`);
            return;
        }

        const imgProduct = parent.childNodes[1];
        const titleProduct = parent.children[1];
        
        const newClone = clone.cloneNode(true);
        const imgClone = newClone.children[0];
        const description = newClone.children[1];
        const count = description.children[1].children[1];
        const titleClone = description.children[0];

        imgClone.src = imgProduct.src;
        titleClone.innerHTML = titleProduct.innerHTML;
        newClone.id = parent.id + "-clone";
        count.innerHTML = "1";
        Array.from(newClone.querySelectorAll("button")).forEach((b) => hoverEffect(b));
        Array.from(newClone.querySelectorAll(".plus")).forEach((b) => incrementFunction(b));
        Array.from(newClone.querySelectorAll(".minus")).forEach((b) => decrementFunction(b));
        
        container.appendChild(newClone);

        localStorage.setItem(`${newClone.id}`, `${count.innerHTML}`);
    });
}

function incrementFunction(buttonReference) {
    buttonReference.addEventListener("click", (e) => {
        const quantity = e.target.parentElement;
        const count = quantity.querySelector(".count");
        count.innerHTML = (parseInt(count.innerHTML) + 1).toString();
        
        const targetClone = e.target.parentElement.parentElement.parentElement;
        const originalId = targetClone.id.slice(0, -6);
        const price = gallery.querySelector("#" + originalId).querySelector(".price");

        itemsCount.innerHTML = (parseInt(itemsCount.innerHTML) + 1).toString();
        total.innerHTML = (parseFloat(total.innerHTML) + parseFloat(price.innerHTML)).toFixed(2).toString();
        localStorage.setItem(`${targetClone.id}`, `${count.innerHTML}`);
    });
}

function decrementFunction(buttonReference) {
    buttonReference.addEventListener("click", (e) => {
        const quantity = e.target.parentElement;
        const count = quantity.querySelector(".count");
        count.innerHTML = (parseInt(count.innerHTML) - 1).toString();
        
        const targetClone = e.target.parentElement.parentElement.parentElement;
        const originalId = targetClone.id.slice(0, -6);
        const price = gallery.querySelector("#" + originalId).querySelector(".price");

        itemsCount.innerHTML = (parseInt(itemsCount.innerHTML) - 1).toString();
        total.innerHTML = (parseFloat(total.innerHTML) - parseFloat(price.innerHTML)).toFixed(2).toString();
        localStorage.setItem(`${targetClone.id}`, `${count.innerHTML}`);
        
        if (count.innerHTML == "0") {
            const description = quantity.parentElement;
            const item = description.parentElement;
            item.remove();
            localStorage.removeItem(`${targetClone.id}`);
            if (container.children.length == 2)
                container.children[0].style.display = "flex";
        }
    });
}

function clearAll(proceeded) {
    let countDeleted = 0;
    Array.from(container.children).forEach((element) => {
        if (element.classList.contains("inventory-item") && element.id !== ("clone")) {
            element.remove();
            countDeleted += 1;
        }
    });
    localStorage.clear();
    localStorage.setItem(`darkmode`, `${isDarkMode}`);
    if (proceeded)
        if (countDeleted > 0)
            alert(`Your purchase has been made!\nThe total would be : \$${total.innerHTML}`);
        else 
            alert(`Your purchase was declined\nPlease place items in Your Cart in order to buy them!`);
    container.querySelector("p").style.display = "flex";
    itemsCount.innerHTML = "0";
    total.innerHTML = "0.00";
}

function tellTotal() {
    if (total.innerHTML != "0.00")
        alert(`The current total would be : \$${total.innerHTML}\nIf you would like to proceed with pruchase:\n\tclick "PROCEED TO CHECKOUT"\nIf you want to clear the cart:\n\tclick "CLEAR"`);
    else 
        alert(`In order to add items to cart:\n\tclick "ADD TO CART" for the desired product`);
}

window.addEventListener("load", () => {
    
    const isDarkModeStorage = localStorage.getItem(`darkmode`);
    isDarkMode = isDarkModeStorage === null || isDarkModeStorage === "false";
    toggleDarkMode();
    
    let countAdded = 0;

    Object.keys(localStorage).forEach((storageKey) => {
        if (storageKey.includes(`-clone`)) {

            const parent = document.getElementById(storageKey.slice(0, -6));
            const price = parent.querySelector(".price");

            itemsCount.innerHTML = (parseInt(itemsCount.innerHTML) + 1).toString();
            total.innerHTML = (parseFloat(total.innerHTML) + parseFloat(price.innerHTML)).toFixed(2).toString();

            const imgProduct = parent.childNodes[1];
            const titleProduct = parent.children[1];
            
            const newClone = clone.cloneNode(true);
            const imgClone = newClone.children[0];
            const description = newClone.children[1];
            const count = description.children[1].children[1];
            const titleClone = description.children[0];

            imgClone.src = imgProduct.src;
            titleClone.innerHTML = titleProduct.innerHTML;
            newClone.id = parent.id + "-clone";
            count.innerHTML = localStorage.getItem(storageKey);
            Array.from(newClone.querySelectorAll("button")).forEach((b) => hoverEffect(b));
            Array.from(newClone.querySelectorAll(".plus")).forEach((b) => incrementFunction(b));
            Array.from(newClone.querySelectorAll(".minus")).forEach((b) => decrementFunction(b));
            
            container.appendChild(newClone);
            countAdded += 1;
        }
    });

    if (countAdded == 0)
        container.querySelector("p").style.display = "flex";
    else
        container.querySelector("p").style.display = "none";
});