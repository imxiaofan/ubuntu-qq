FROM kasmweb/core-ubuntu-jammy:1.16.1

LABEL version="1.0" maintainer="imxiaofan<imxiaofan@163.com>"

USER root
RUN apt-get update && apt-get install -y cron jq wget xdotool xclip imagemagick tesseract-ocr libtesseract-dev zsh
RUN wget https://dldir1.qq.com/qqfile/qq/QQNT/Linux/QQ_3.2.16_250401_amd64_01.deb -O /qq.deb \
    && apt --fix-broken install -y /qq.deb
RUN apt autoremove -y \
    && apt clean \
    && rm -rf /*.deb \
    && rm -rf /var/lib/apt/lists/*
ENV TZ=Asia/Shanghai
RUN ln -snf /usr/share/zoneinfo/$TZ /etc/localtime && echo $TZ > /etc/timezone
RUN sed -i "s/^wait_on_printer/#wait_on_printer/; s/^start_audio/#start_audio/; s/^start_upload/#start_upload/; s/^start_gamepad/#start_gamepad/; s/^profile_size_check/#profile_size_check/; s/^start_webcam/#start_webcam/; s/^start_printer/#start_printer\nsudo service cron start/" /dockerstartup/vnc_startup.sh
RUN chmod u+w /etc/sudoers && sed -i '$ i\kasm-user	ALL=(ALL:ALL) NOPASSWD:/usr/sbin/service cron start' /etc/sudoers && chmod u-w /etc/sudoers

USER kasm-user
# Install oh-my-zsh & plugins
RUN sh -c "$(wget https://raw.github.com/ohmyzsh/ohmyzsh/master/tools/install.sh -O -)"
RUN git clone https://github.com/zsh-users/zsh-autosuggestions ${ZSH_CUSTOM:-/home/kasm-user/.oh-my-zsh/custom}/plugins/zsh-autosuggestions
RUN git clone https://github.com/zsh-users/zsh-syntax-highlighting.git ${ZSH_CUSTOM:-/home/kasm-user/.oh-my-zsh/custom}/plugins/zsh-syntax-highlighting 
RUN sed -i "s/plugins=(git)/plugins=(git zsh-autosuggestions zsh-syntax-highlighting)/" /home/kasm-user/.zshrc
# set default shell to zsh
RUN mkdir -p /home/kasm-default-profile/.config/xfce4/terminal && echo "[Configuration]\nCustomCommand=zsh\nRunCustomCommand=TRUE" > /home/kasm-default-profile/.config/xfce4/terminal/terminalrc
# move the panel to the bottom
RUN sed -i "s/p=6;x=0;y=0/p=8;x=943;y=895/" /home/kasm-default-profile/.config/xfce4/xfconf/xfce-perchannel-xml/xfce4-panel.xml
