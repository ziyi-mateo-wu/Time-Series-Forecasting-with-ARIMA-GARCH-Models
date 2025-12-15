# Time-Series Forecasting: ARIMA & GARCH Framework 📈

> A rigorous econometric analysis of **S&P 500 Industrials**, addressing the limitations of mean-reversion models through Volatility Clustering (GARCH).

[![Status](https://img.shields.io/badge/Statistical%20Rigor-Ljung--Box%20Verified-success?style=for-the-badge)](https://github.com/ziyi-mateo-wu)
[![Language](https://img.shields.io/badge/R-4.0%2B-blue?style=for-the-badge&logo=r)](https://www.r-project.org/)
[![Model](https://img.shields.io/badge/Model-ARIMA%20%7C%20GARCH(1%2C1)-orange?style=for-the-badge)](https://github.com/ziyi-mateo-wu)

### 📌 Project Context & Data
This project analyzes the **S&P 500 Industrials Index** (Period 1). The initial data exploration revealed typical "Stylized Facts" of financial assets:
* **Price Level:** Non-stationary with a persistent upward trend.
* **Log Returns:** Stationary but exhibiting distinct **Volatility Clustering** (periods of calm followed by turbulent outbursts).

This necessitates a **Dual-Process Approach**: using ARIMA for the mean equation and GARCH for the variance equation.

---

### 📊 Key Empirical Results (The "Hard Numbers")

The analysis prioritized statistical validity over overfitting.

#### 1. Mean Dynamics (ARIMA)
* **Model Selection:** Optimized based on AIC minimization and residual diagnostics.
* **Goodness-of-Fit:** The model achieved a **Ljung-Box p-value of 0.7028**, strictly failing to reject the null hypothesis of independence. This confirms that **residuals are White Noise** and the model successfully captured all linear autocorrelation.
* **Forecasting Reality:** The out-of-sample forecast yielded a **MAPE of 12.35%**. This relatively weak predictive power for the *mean* reinforces the Efficient Market Hypothesis (EMH) and motivates the shift to modeling *risk* (variance) instead of *price*.

#### 2. Volatility Dynamics (GARCH 1,1)
* **Specification:** A GARCH(1,1) model was deployed to capture the heteroscedasticity observed in the squared residuals.
* **Persistence:** The sum of $\alpha$ (ARCH) and $\beta$ (GARCH) coefficients indicated high volatility persistence, suggesting that market shocks in the Industrials sector have a long-lasting memory effect.

---

### 🏗️ Modeling Pipeline

The workflow follows strict econometric standards:

1.  **Stationarity Testing:** Augmented Dickey-Fuller (ADF) tests to confirm $I(1)$ to $I(0)$ transformation.
2.  **Model Diagnostics:**
    * **ACF/PACF Plots:** Visual inspection of serial correlation.
    * **Ljung-Box Test:** Statistical verification of residual independence ($p > 0.05$).
3.  **Risk Forecasting:** Generating conditional volatility forecasts to quantify future market risk.

---

### 📄 Full Research Paper

For a deeper dive into the mathematical derivations and literature review, the full academic report is available below.

[![Read Full Report](https://img.shields.io/badge/Read%20Full%20Paper-PDF-red?style=for-the-badge&logo=adobeacrobatreader&logoColor=white)](https://github.com/ziyi-mateo-wu/Time-Series-Forecasting-with-ARIMA-GARCH-Models/blob/main/individual%20project/FIN3018_Individual_Report_S.pdf)

### 📉 Detailed Visualizations

<details>
<summary>
  <img src="https://img.shields.io/badge/CLICK_HERE_TO_EXPAND-CHARTS_%26_VISUALIZATIONS-FF4500?style=for-the-badge&logo=google-analytics&logoColor=white" alt="Click to Expand">
</summary>
<br>

#### 1. Volatility Forecast with Confidence Cones
Visualizing the conditional sigma (risk) projection for S&P 500 Industrials.
<img width="100%" alt="Volatility Forecast" src="forecast_plot.png" />

#### 2. Residual Diagnostics
Confirming the "White Noise" property of residuals (No significant autocorrelation).
<img width="100%" alt="Residual Diagnostics" src="residual_diagnostics.png" />

<br>
<p align="center">
  <a href="sp500_garch_volatility.R">
    <img src="https://img.shields.io/badge/View_R_Source_Code-.R_File-blue?style=for-the-badge&logo=r" alt="View Code">
  </a>
</p>

</details>

---

### 💻 How to Run

1.  Clone the repository.
2.  **Data Setup:** Ensure `sp500_historical.csv` is located in the `data/` folder.
3.  Open `sp500_garch_volatility.R` in **RStudio**.
4.  Install dependencies: `rugarch`, `forecast`, `tseries`.
5.  Run the script to reproduce the Ljung-Box test results ($p \approx 0.70$).
