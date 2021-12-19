#include "bsdk.h"

void main(void) {
    // ADA是I2S单声道声音采样IP(ADA/Audacq = audio data acquisitor)
    ada_sample_t sample;

    // 初始化LED/板载BTN1
    gpio_init();

    // ADA配置
    //   参数1决定ADA内建滤波器是否生效
    //   参数2定义采样信号截位宽度
    //     外部音量过大时可以增大截位(防止饱和/溢出),外部音量过小时可以减小截位(提升分辨率)
    ada_configure(false, 4u);

    recording_stopped:

    // 呼吸灯:Stand by
    // 收到串口数据退出呼吸,开始声音采样
    uart_clear_rxq();
    while (true)
        for (int t=0; t<2; t++) {
            for (int dc=0; dc<64; dc++) {
                for (int c=0; c<64; c++) {
                    timer_set(256u);
                    while (timer_get())
                        if (uart_rx_ready())
                            goto recording_started;
                    light_leds((t & 0x1u) ? (c>dc) : (c<=dc), false, false);
                }
            }

            if (t & 0x1u) {
                timer_set(768u*256u);
                while (timer_get())
                    if (uart_rx_ready())
                        goto recording_started;
            }
        }

    recording_started:
    // 防止LED出现窄脉冲闪烁
    timer_delay_us(8u);
    light_leds(false, false, false);

    uart_clear_rxq();
    // 持续接收声音信号: Busy
    // 声音信号样本会从串口持续发出
    // 收到串口数据退出接收,返回呼吸灯
    while (!uart_rx_ready()) {
        while(!ada_get_sample(&sample));
        uart_send_data(sample.data, 2u);
    }

    goto recording_stopped;
}
