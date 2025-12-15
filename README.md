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

### 📉 Empirical Evidence & Visual Diagnostics

The following visualizations document the rigorous statistical validation process, confirming the transition from raw data to a validated GARCH framework.

<details>
<summary>
  <img src="https://img.shields.io/badge/CLICK_HERE_TO_EXPAND-EMPIRICAL_%26_DIAGNOSTIC_PLOTS-FF4500?style=for-the-badge&logo=google-analytics&logoColor=white" alt="Click to Expand">
</summary>
<br>

#### 1. Stylized Facts: The Necessity of Transformation
**Observation:** The raw S&P 500 Industrials index (Top) exhibits a non-stationary upward trend ($d=1$). After differencing, the **Log Returns** (Bottom) oscillate around zero ($d=0$), fulfilling the stationarity requirement for ARIMA modeling, yet revealing distinct **Volatility Clustering** (heteroscedasticity).
<img width="1037" height="773" alt="image" src="https://github.com/user-attachments/assets/69c70837-acca-4270-99ad-4978ef678dcf" />


<br>

#### 2. Serial Correlation Analysis (ACF/PACF)
**Diagnostic:** The Autocorrelation Function (ACF) of squared returns shows significant spikes, rejecting the Null Hypothesis of independence. This explicitly confirms the presence of **ARCH effects** (autoregressive conditional heteroscedasticity), validating the rejection of simple OLS in favor of a GARCH specification.
<img width="1037" height="773" alt="image" src="https://github.com/user-attachments/assets/cc07e3b8-ccc1-46bd-9c0e-d0181fe177a0" />
<img width="1037" height="773" alt="image" src="https://github.com/user-attachments/assets/b4b467a5-da0e-4015-81f4-c9d18aa9b380" />



<br>

#### 3. Model Validation: Residual Diagnostics
**Verification:** Post-estimation analysis of the ARIMA-GARCH residuals.
* **Standardized Residuals:** Conform to a White Noise process.
* **QQ-Plot:** The Student-t distribution (blue line) fits the empirical data tails significantly better than the Normal distribution, accounting for the asset's **Leptokurtic (Fat Tail)** nature.
* **Ljung-Box Test:** The resulting p-value of **0.7028** confirms no remaining autocorrelation.
<img width="1037" height="773" alt="image" src="https://github.com/user-attachments/assets/7bb0205e-fdf3-4c37-b945-44ec8f11be5a" />


<br>

#### 4. The Risk Cone: 10-Day Volatility Forecast
**Outcome:** Unlike the static mean forecast, the Variance Equation produces a dynamic risk envelope. The widening **95% Confidence Intervals** ($\pm 1.96 \hat{\sigma}_{t+h}$) visually quantify the increasing uncertainty over the forecast horizon.
<img width="1037" height="773" alt="image" src="https://github.com/user-attachments/assets/e5f050d8-ca1a-40cd-8a0b-bdb01d445071" />


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
