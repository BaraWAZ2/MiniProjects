const button = document.getElementById("calculate");
const height = document.getElementById("height");
const weight = document.getElementById("weight");
const results = document.getElementById("results");
const classify = document.getElementById("classify");

function calcBMI(height_cm, weight_kg) {
    return weight_kg / ((height_cm / 100) ** 2);
}

function classifyBMI(bmi) {
    if (bmi < 10 || bmi > 50)
        return "Inhuman";
    if (bmi < 18.5)
        return "Underweight";
    if (bmi < 24.9)
        return "Normal weight";
    if (bmi < 29.9)
        return "Overweight";
    if (bmi >= 30)
        return "Obese";
}

button.addEventListener("mouseover", (e) => {
    button.style.backgroundColor = "rgb(77, 77, 156)";
});

button.addEventListener("mouseout", (e) => {
    button.style.backgroundColor = "rgb(99, 99, 226)";
});

function showResult(e) {
    e.preventDefault();
    if (!height.value) {
        results.textContent = "Insert height first!";
        classify.textContent = "";
    }
    else if (!weight.value) {
        results.textContent = "Insert weight first!";
        classify.textContent = "";
    }
    else {
        const bmi = calcBMI(height.value, weight.value);
        const bmiMessage = "Your BMI is " + bmi.toFixed(2);
        const classification = classifyBMI(bmi);
        results.textContent = bmiMessage;
        classify.textContent = classification;
    }
}

function updateResult() {
    if (weight.value && height.value) {
        const bmi = calcBMI(height.value, weight.value);
        const bmiMessage = "Your BMI is " + bmi.toFixed(2);
        const classification = classifyBMI(bmi);
        results.textContent = bmiMessage;
        classify.textContent = classification;
    }
}

button.addEventListener("click", (e) => showResult(e));