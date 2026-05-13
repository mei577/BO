# Constrained Bayesian Optimization for Process Discovery and Optimization

[![MATLAB](https://img.shields.io/badge/MATLAB-R2021a%2B-orange.svg)](https://www.mathworks.com/products/matlab.html)
[![License](https://img.shields.io/badge/License-MIT-blue.svg)](LICENSE)

This repository provides a framework for **Constrained Bayesian Optimization (CBO)** applied to 5-dimensional chemical or physical systems. It is designed to maximize a specific output (Yield) while adhering to strict safety or quality thresholds (Purity $\ge 98\%$).

---

## 📌 Project Overview

Optimizing complex processes often involves balancing multiple parameters where experiments are costly or time-consuming. This tool uses Gaussian Process (GP) surrogate models to predict system behavior and Acquisition Functions to suggest the most promising next experiments.

### Mathematical Formulation
* **Objective:** Maximize $Yield$ (implemented as minimizing $-Yield$).
* **Constraints:** $Purity \ge 98\%$ (implemented as $98 - Purity \le 0$).
* **Search Space:** 5 continuous parameters (`para1` to `para5`) with defined physical bounds.

---

## 🚀 Optimization Strategies

You can choose from three distinct acquisition strategies based on your optimization goals:

| Strategy | Script | Description |
| :--- | :--- | :--- |
| **cEI** | `bo_cEI.m` | **Constrained Expected Improvement**: Balances exploration of unknown areas and exploitation of known good areas. |
| **cPI** | `bo_cPI.m` | **Constrained Probability of Improvement**: Focuses on finding points with the highest probability of surpassing the current best result. |
| **HDM** | `bo_HDM.m` | **Hybrid Decision Model**: A two-phase approach. It uses **cEI** for the first 75% of iterations for global search and switches to **cPI** for the final 25% for fine-tuning. |

---

## 🛠 Workflow & Usage

The project follows a "Human-in-the-loop" or "Experimental-Feedback" workflow.

### Step 1: Initialization
Run `initialization.m`. 
* This script uses **Latin Hypercube Sampling (LHS)** to generate 20 initial points.
* It creates a file named `Initial_data.xlsx`.
* **Sheet 1:** Contains the 5D input parameters for your initial experiments.
* **Sheet 2:** Contains placeholder virtual data.

### Step 2: Experimental Feedback
1.  Perform the experiments suggested in `Initial_data.xlsx` (Sheet 1).
2.  Open `Initial_data.xlsx` and go to **Sheet 2**.
3.  Replace the placeholder values with your **measured Yield** and **measured Purity** for each corresponding row.

### Step 3: Bayesian Optimization
Choose an optimization script (e.g., `bo_HDM.m`) and run it.
* The script will load your initial data from `Initial_data.xlsx`.
* During the loop, MATLAB will suggest new parameters in the command window.
* You will be prompted to enter the results:
    ```text
    Enter Measured Yield: 
    Enter Measured Purity: 
    ```
* **Real-time Persistence:** After every iteration, the results are automatically saved to an Excel file (e.g., `bo_HDM.xlsx`) to prevent data loss.

---

## 📂 File Structure

* `initialization.m`: Initial sampling and template generation.
* `bo_cEI.m`: Main loop using the Expected Improvement strategy.
* `bo_cPI.m`: Main loop using the Probability of Improvement strategy.
* `bo_HDM.m`: Main loop using the Hybrid (cEI + cPI) strategy.
* `Initial_data.xlsx`: Data bridge between sampling and optimization.

---

## 📊 Visualization

The scripts include built-in visualization tools to track:
1.  **Objective Value:** Progression of the best found Yield.
2.  **Constraint Feasibility:** Evaluation of the Purity threshold model.
3.  **Parameter Importance:** Insights into which parameters drive system performance.

---

## 💻 Requirements

* **MATLAB R2021a** or newer.
* **Statistics and Machine Learning Toolbox**.

---

## License

This project is licensed under the MIT License.
