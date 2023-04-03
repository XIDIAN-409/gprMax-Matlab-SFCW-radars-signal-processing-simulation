# 基于gprMax以及Matlab仿真的SFCW雷达信号处理笔记
English Version <a href='.\README.EN.md'>README</a>

>本人为初学者，且不常使用github，如遇到问题可发送邮件至**2538703415@qq.com**讨论，这样我能及时看见，但不一定能帮你解决……

> 当前使用gprMax进行探地雷达仿真主要存在以下两个问题，它们分别是：
> - `gprMax无法直接对一段完整的SFCW信号进行仿真`，若要通过gprMax直接实现SFCW信号的回波仿真，则要将一段完整的SFCW信号拆分成若干段频率单一的余弦信号分别进行仿真，对于拥有上百个频点的SFCW信号而言，需要进行上百次单独的仿真。
> - 使用自定义波形或gprMax内置波形进行仿真时，`仿真速度偏低且灵活性差，每次在用户需要更改波形时，都要重新开始仿真`。

对于提到的这些问题，包括gprMax开发团队在内的很多研究团体都得出了一些解决方案，这份readme文档将对这些解决方案进行归纳总结。这一仓库中的代码最终实现如下结果：

<p style="text-align:center">
    <img src='.\images\model.png'>
</p>
<p style="text-align:center">图一：gprMax模型</p>

<p style="text-align:center">
    <img src='.\images\result.png'>
</p>
<p style="text-align:center">图二：Matlab仿真结果</p>


|   根目录文件    |   文件作用    |
|   ----   |   ----         |
|main.m       |运行此文件，执行matlab仿真|
|simu_single_step.m       |运行此文件，执行matlab仿真（无图）|
|result.mat       |对应bscan_impulse_merged.out的仿真结果|
|result_10m.mat       |对应bscan_impulse_merged_10m.out的仿真结果|

|   impulse_lib文件夹    |   文件作用    |
|   ----   |   ----         |
|bscan_impulse_10m_merged.out       |对应bscan_impulse_10m.in的bscan冲激响应输出结果|
|bscan_impulse_merged.out       |对应bscan_impulse.in的bscan冲激响应输出结果|

|   gprMax_source文件夹    |   文件作用    |
|   ----   |   ----         |
|sfcw_impulse.in      |模型1的输入文件，可用于生成vti，对应bscan子文件夹中的bscan_impulse.in|
|sfcw_impulse_10m.in      |模型2的输入文件，可用于生成vti，对应bscan子文件夹中的bscan_impulse_10m.in|
|impulse_response_10m.vti     |模型2（对应图一）的vti文件|

---

## 冲激响应法求解回波模型

为了解决gprMax仿真灵活性差，耗时长的问题，可以采用信号与系统中的基础知识，通过将模拟场景视为一个线性时不变系统（LTI system），将输入信号（也就是用户自定义的发射信号）与这一LTI系统的冲激响应h(t)相卷积，从而得到对应于输入信号的模拟场景回波信号。

<p style="text-align:center">
    <img src='.\images\lti-system.png'>
</p>
<p style="text-align:center">图三：冲激响应计算y(t)</p>

在通过一次仿真求得系统的冲激响应之后，用户只需要在matlab中将输入信号与此冲激响应相卷积，就可以得到对应的回波模型。`gprMax提供了冲激信号波形（impulse），但是没有在对应的参考文献中列出`，此波形可以直接使用，在使用时，其他波形对应的中心频率项对impulse波形不再生效（毕竟冲激信号只有tn=0时有值）。

具体的操作方法不在此处详细列出，对应的生成系统冲激响应的文件在<a href='.\gprMax_source\sfcw_impulse.in'>此处</a>可以查看。

这一部分的具体操作可参考：
    
- https://blog.csdn.net/l_jsaphsj/article/details/127530336?spm=1001.2014.3001.5501
- https://www.youtube.com/watch?v=_FWNeqTr9nc&t=1387s （gprMax官方）

---

## SFCW信号回波的仿真（gprMax & Matlab）

SFCW雷达每次发射和接收的信号为单频连续波信号，其频率变化可表示为：
$$f_n = f_0 + (n-1)\Delta f$$
其中 $f_n$ 是当前（第n个）频率， $f_0$ 是起始频率， $\Delta f$ 为频率步长。

发射信号可以被表示为：
$$T_x(n) = sin(2\pi f_nt)$$
其中n为第n个频点。

假设信号在均匀介质中的传播速度为 $v$ ，则一个距离目标为 $R$ 的物体所反射的回波信号可以表示为：
$$R_x(n) = A_nsin[2\pi f_n(t - \frac{2R}{v})]$$
其中 $A_n$ 为回波幅度， $\frac{2R}{v}$ 是信号的双程走时。

第n个频率的相位变化可对应表示为：
$$\Phi_n = 2\pi f_n\frac{2R}{v}$$
接收到的回波信号由此可以表示为：
$$R_x(n) = A_nsin(2\pi f_nt - \Phi_n)$$

>**不同的频点对应着不同的相移，这些相位信息对于特定的某个频点而言是一个常数，但是将SFCW信号中的几十至几百甚至更多频点的相位信息结合之后，能够得到一个具有周期性的相位信号，将这个信号进行ifft变换，即可得到对应于距离的时域信息。**

<p style="text-align:center">
    <img src='.\images\systemStructure.png'>
</p>
<p style="text-align:center">图四：雷达系统框图</p>

图四中的I和Q分量可通过如下公式进行计算：

$$I_n = A_nsin(2\pi f_nt-\Phi_n)*sin(2\pi f_nt) = \frac{An}{2}sin(4\pi f_nt-\Phi_n) - \frac{A_n}{2}cos(\Phi_n)$$
$$I_n = A_nsin(2\pi f_nt-\Phi_n)*cos(2\pi f_nt) = \frac{An}{2}sin(4\pi f_nt-\Phi_n) - \frac{A_n}{2}sin(\Phi_n)$$

在通过低通滤波器之后，可以提取出I和Q对应的差频分量为：
$$I_n = -\frac{A_n}{2}cos(\Phi_n)$$
$$Q_n = -\frac{A_n}{2}sin(\Phi_n)$$
> `注意在经过LPF之后需要对两部分差频分量进行组合`,即输入ADC的信号应当为如下形式：
> $$ADC_{in}(n) = I_n + jQ_n$$

对于经过IFFT处理后得到的时域信号，其**横坐标轴的长度**由ADC采样点数决定，其**横坐标轴的精度**由SFCW信号的带宽决定，设SFCW信号的带宽为 $B$ ，则其横坐标轴可表示为：
$$t = 0:\frac{1}{B}:\frac{N_t-1}{B}$$
其中$N_t$是ADC采样点数。

---

## gprMax生成模型时的注意事项

>本人设计的<a href='.\gprMax_source\sfcw_impulse.in'>in文件</a>中，包含一项*time_step_stability_factor*参数，这一参数的具体用法可以参考官方文件，其作用主要是将dt进行手动调整（比如设置为1e-11s）。设置这一参数的主要目的是使gprMax中的dt和Matlab中的采样时间间隔dt相同，以方便仿真（两个dt不相同会怎样这个我也没试过，应该也行问题不大）。

**gprMax中网格步长参数的设置**

根据官方给出的文档，gprmax模型中的网格步长不能大于模型介质中最短波长的十分之一,即：
$$calc_{dxyz} \leq \frac{1}{10}\frac{c}{f_{max}\sqrt{\epsilon_{max}}} $$

这项参数的最大值可以通过func文件夹中的<a href='.\gprMax_source\sfcw_impulse.in'>calc_dxyz函数</a>进行快速计算。

**拆分后的单频率信号波形设置**

在使用冲激响应方法，通过卷积获得输出信号波形时，`如果直接输入一个完整的单频正弦信号，会导致卷积结果中包含大量高频噪声`，因此，在设置输入的单频正弦信号时，需要逐渐提升信号幅值，其信号波形如下所示：

<p style="text-align:center">
    <img src='.\images\single_sine.png'>
</p>
<p style="text-align:center">图五：单频余弦信号</p>

图五所示的信号在gprMax中对应的波形名称为contsine，其公式如下所示：

$$T_x(t) = \begin{cases}
    kf_ntsin(2\pi f_nt) & kf_nt <1\\
    \\
    sin(2\pi f_nt) & kf_nt \geq 1
\end{cases}$$

在gprMax的waveforms.py中， $k = 0.25$