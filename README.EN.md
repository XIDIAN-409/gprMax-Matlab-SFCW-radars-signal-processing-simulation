# Signal processing simulation of SFCW radars using gprMax & Matlab

>I am a beginner and I don’t often use github. If you encounter any problems, you can send an email to **2538703415@qq.com** for discussion, but I may not be able to help you solve it...

> At present, there are two main problems in GPR simulation using gprMax, which are:
> - `gprMax cannot directly simulate a complete SFCW signal`, if you want to directly realize the echo simulation of the SFCW signal through gprMax, you need to split a complete SFCW signal into several cosine signals with a single frequency for simulation , for SFCW signals with hundreds of frequency points, hundreds of separate simulations are required.
> - When using custom waveforms or gprMax built-in waveforms for simulation, the simulation speed is low and the flexibility is poor. Every time the user needs to change the waveform, the simulation must be restarted.

For these problems mentioned, many research groups including the gprMax development team have come up with some solutions, and this readme document will summarize these solutions. The code in this warehouse finally achieves the following results:

<p style="text-align:center">
    <img src='.\images\model.png'>
</p>
<p style="text-align:center">Fig 1. gprMax model</p>

<p style="text-align:center">
    <img src='.\images\result.png'>
</p>
<p style="text-align:center">Fig 2.Matlab simulation result</p>

| root directory file | file function |
| ---- | ---- |
|main.m |Run this file, perform matlab simulation|
|simu_single_step.m |Run this file to perform matlab simulation (no picture)|
|result.mat |Simulation results corresponding to bscan_impulse_merged.out|
|result_10m.mat |Simulation result corresponding to bscan_impulse_merged_10m.out|

| impulse_lib folder | file function |
| ---- | ---- |
|bscan_impulse_10m_merged.out |The bscan impulse response output corresponding to bscan_impulse_10m.in|
|bscan_impulse_merged.out |The bscan impulse response output corresponding to bscan_impulse.in|

| gprMax_source folder | file function |
| ---- | ---- |
|sfcw_impulse.in |The input file of model 1, which can be used to generate vti, corresponds to bscan_impulse.in in the bscan subfolder|
|sfcw_impulse_10m.in |The input file of model 2, which can be used to generate vti, corresponds to bscan_impulse_10m.in in the bscan subfolder|
|impulse_response_10m.vti |vti file of model 2 (corresponding to Fig 1)|

---

## Impulse response method to solve the echo model

In order to solve the problem of poor flexibility and time-consuming of gprMax simulation, the basic knowledge of signal and system can be used to treat the simulation scene as a linear time-invariant system (LTI system), and the input signal (that is, the user-defined emission signal) is convolved with the impulse response h(t) of this LTI system to obtain a simulated scene echo signal corresponding to the input signal.

<p style="text-align:center">
     <img src='.\images\lti-system.png'>
</p>
<p style="text-align:center">Figure 3: Impulse response calculation</p>

After obtaining the impulse response of the system through a simulation, the user only needs to convolve the input signal with the impulse response in matlab to obtain the corresponding echo model. `gprMax provides the impulse signal waveform (impulse), but it is not listed in the corresponding references`. This waveform can be used directly. When using it, the center frequency item corresponding to other waveforms is no longer valid for the impulse waveform (after all, the impulse waveform The excitation signal has a value only when tn=0).

The specific operation method is not listed here in detail, and the corresponding file for generating the system impulse response can be viewed in <a href='.\gprMax_source\sfcw_impulse.in'>here</a>.

The specific operation of this part can refer to:
- https://blog.csdn.net/l_jsaphsj/article/details/127530336?spm=1001.2014.3001.5501
- https://www.youtube.com/watch?v=_FWNeqTr9nc&t=1387s （gprMax official）

---

## Simulation of SFCW signal echo (gprMax & Matlab)

The signal transmitted and received by the SFCW radar is a single-frequency continuous wave signal, and its frequency change can be expressed as:
$$f_n = f_0 + (n-1)\Delta f$$
Where $f_n$ is the current (nth) frequency, $f_0$ is the starting frequency, and $\Delta f$ is the frequency step size.

The emission signal can be expressed as:
$$T_x(n) = sin(2\pi f_nt)$$
Where n is the nth frequency point.

Assuming that the propagation speed of the signal in a homogeneous medium is $v$, the echo signal reflected by an object with a distance of $R$ from the target can be expressed as:
$$R_x(n) = A_nsin[2\pi f_n(t - \frac{2R}{v})]$$
Where $A_n$ is the echo amplitude, and $\frac{2R}{v}$ is the two-way travel time of the signal.

The phase change of the nth frequency can be expressed as:
$$\Phi_n = 2\pi f_n\frac{2R}{v}$$
The received echo signal can thus be expressed as:
$$R_x(n) = A_nsin(2\pi f_nt - \Phi_n)$$

>** Different frequency points correspond to different phase shifts. These phase information is a constant for a specific frequency point, but the phase information of tens to hundreds or even more frequency points in the SFCW signal is combined Afterwards, a periodic phase signal can be obtained, and the time domain information corresponding to the distance can be obtained by performing ifft transformation on this signal. **

<p style="text-align:center">
    <img src='.\images\systemStructure.png'>
</p>
<p style="text-align:center">Fig 4. Block diagram of SFCW radar</p>

The I and Q components in Fig 4 can be calculated by the following formula:

$$I_n = A_nsin(2\pi f_nt-\Phi_n)*sin(2\pi f_nt) = \frac{An}{2}sin(4\pi f_nt-\Phi_n) - \frac{A_n}{2} cos(\Phi_n)$$
$$I_n = A_nsin(2\pi f_nt-\Phi_n)*cos(2\pi f_nt) = \frac{An}{2}sin(4\pi f_nt-\Phi_n) - \frac{A_n}{2} sin(\Phi_n)$$

After passing through the low-pass filter, the difference frequency components corresponding to I and Q can be extracted as:
$$I_n = -\frac{A_n}{2}cos(\Phi_n)$$
$$Q_n = -\frac{A_n}{2}sin(\Phi_n)$$
> `Note that the two parts of the difference frequency components need to be combined after passing through the LPF`, that is, the signal input to the ADC should be in the following form:
> $$ADC_{in}(n) = I_n + jQ_n$$

For the time-domain signal obtained after IFFT processing, the length of the **abscissa axis** is determined by the number of ADC sampling points, and the accuracy of the **abscissa axis** is determined by the bandwidth of the SFCW signal. Let the bandwidth of the SFCW signal be $B$, then its abscissa axis can be expressed as:
$$t = 0:\frac{1}{B}:\frac{N_t-1}{B}$$
Where $N_t$ is the number of ADC sampling points.

---

## Precautions when gprMax generates models

>The <a href='.\gprMax_source\sfcw_impulse.in'>in file</a> I designed contains a *time_step_stability_factor* parameter. For the specific usage of this parameter, please refer to the official document. Its main function is to dt is manually adjusted (e.g. set to 1e-11s). The main purpose of setting this parameter is to make the dt in gprMax the same as the sampling time interval dt in Matlab to facilitate the simulation (I haven't tried what happens if the two dt are different, and it shouldn't be a big problem).

**Setting of grid step parameters in gprMax**

According to the official documents, the grid step size in the gprmax model cannot be greater than one-tenth of the shortest wavelength in the model medium, namely:
$$calc_{dxyz} \leq \frac{1}{10}\frac{c}{f_{max}\sqrt{\epsilon_{max}}} $$

The maximum value of this parameter can be quickly calculated by the <a href='.\gprMax_source\sfcw_impulse.in'>calc_dxyz function</a> in the func folder.

**Single-frequency signal waveform setting after splitting**

When the impulse response method is used to obtain the output signal waveform through convolution, `if a complete single-frequency sinusoidal signal is directly input, a large amount of high-frequency noise will be included in the convolution result`, therefore, when setting the input single-frequency sinusoidal When using a signal, it is necessary to gradually increase the signal amplitude, and the signal waveform is as follows:

<p style="text-align:center">
     <img src='.\images\single_sine.png'>
</p>
<p style="text-align:center">Fig 5: transmit signal (single frequency)</p>

The waveform name corresponding to the signal shown in Figure 5 in gprMax is constine, and its formula is as follows:

$$T_x(t) = \begin{cases}
     kf_ntsin(2\pi f_nt) & kf_nt <1\\
     \\
     sin(2\pi f_nt) & kf_nt \geq 1
\end{cases}$$

if using gprMax to generate a contsine wave, $k = 0.25$