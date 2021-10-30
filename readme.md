# 概览
femto 是一款兼容 RISCV 指令的轻量级软核微控制器，可嵌入 FPGA，便于用软件实现一定复杂度的控制逻辑。目前 femto 在 MIT 协议下开源发布。femto 基本特性列表如下：
- 单处理器核
- 可定制的 IP 核
- 内部 32 位单总线
- 同步系统，单个时钟域
- 支持指令预取
- 二级流水线
- RV32EC 指令集，支持 Zfencei 扩展
- 多数指令为单周期指令
- 无中断机制，无高速缓存，尚不支持调试功能
- 内置 MCU 常用 IP 核，便于使用 SRAM/NOR/UART
- 商密硬件加速(待实现)

# 目录树导航

femto
- project: Vivado(RTL)工程
- rtl: RTL源代码
  - fpga: FPGA封装层
    - constraints: 约束
    - imp: femto主体
    - sim: 仿真验证所需的RTL环境
      - ut_core: 处理器核仿真验证
- src: 软件代码
  - imp: 引导程序/Flashloader/示例应用程序
  - linker: 关键ld连接脚本
  - sdk: 软件开发包
  - tools: 脚本工具
  - ut_soc: SoC仿真验证程序
- clean.bat: 清理运行环境
- init.bat: 初始化仿真验证环境
- LICENSE: 开源许可(MIT)
- manual.pdf: femto手册
