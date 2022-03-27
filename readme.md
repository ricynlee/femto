> **`TODO`** enable IP modules' interrupt request to EIC/实现IP模块输出中断请求,并连接到EIC  

# Brief
`femto` is a RISCV ISA-compatible light-weight soft-core MCU that can be implemented on an FPGA for DIY or educational purposes. `femto` is now released under MIT license. Here are some basic features of `femto`:  
- Mono core
- Harvard architecture with 32-bit instruction and data buses
- Fully synchronous design
- Instruction prefetch
- 2-stage pipeline
- Little-endian byte order
- RV32EC ISA with Zifencei & Zicsr extension
- Support external interrupts
- Single-cycle instructions in the majority 
- SRAM/NOR/UART support
- No cache
- No debug support so far

# Project tree
femto
- project: Vivado(RTL) project
- rtl: HDL code
  - fpga: FPGA wrapper
    - constraints: io, timing XDC files
  - imp: `femto` implementation
  - sim: RTL simulation environment
    - periph: virtual peripherals for simulation
    - simfeature: useful features of testbench, e.g. print
    - ut_core: RTL simulation files for processor core (actually never did stand-alone verification of core)
  - tools: script tools, e.g. for IP generation
- src: software code
  - imp: bootloader/flashloader/demo application
    - rom: bootloader project
    - flashloader: flashloader project
    - app: simple demo
  - linker: key ld linking scripts
  - sdk: software development kit/board-level software development kit
  - tools: script tools, e.g. for binary executable file to HDL conversion
  - ut_soc: SoC validation program code
- clean.bat: project-wide environment clean-up
- init.bat: simulation environment initialization
- LICENSE: open-source license (MIT)
- manual.pdf: `femto` reference manual

***

# 概览
`femto`是一款兼容RISCV指令的轻量级软核微控制器,可嵌入FPGA,主要面向DIY和学习目的。目前`femto`在MIT协议下开源发布。`femto`基本特性列表如下:  
- 单处理器核
- 哈佛结构,32位数据总线和指令总线
- 全同步设计,单时钟域
- 指令预取
- 2级流水线
- 小端字节序
- RV32EC指令集,支持Zifencei、Zicsr扩展
- 支持外部中断
- 单周期指令居多
- 内置MCU常用的SRAM/NOR/UART控制器模块
- 无高速缓存(Cache)
- 尚不支持调试

# 目录树导航
femto
- project: Vivado(RTL)工程
- rtl: HDL源代码
  - fpga: FPGA封装层
    - constraints: 输入输出、时序约束
  - imp: `femto`实现主体
  - sim: 仿真验证所需的RTL环境
    - periph: 仿真验证所需的虚拟外设
    - simfeature: 仿真环境的小功能,如打印
    - ut_core: 处理器核仿真验证RTL环境(其实并未单独验证处理器核)
  - tools: 脚本工具,可生成IP等
- src: 软件代码
  - imp: 引导程序/Flashloader/示例应用程序
    - rom: Bootloader引导程序工程
    - flashloader: flashloader工程
    - app: 简单的测试应用
  - linker: 关键ld连接脚本
  - sdk: 软件开发包/板级软件开发包
  - tools: 脚本工具,可用于二进制到HDL转换等
  - ut_soc: SoC仿真验证程序
- clean.bat: 清理运行环境
- init.bat: 初始化仿真验证环境
- LICENSE: 开源许可(MIT)
- manual.pdf: femto参考手册
