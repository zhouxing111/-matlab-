%% 杨氏双缝干涉 MATLAB 仿真系统
% 运行方式：Young_GUI

function Young_GUI

clc; close all;

%% ================== 主界面 ==================

fig = figure('Name','杨氏双缝干涉仿真', ...
    'NumberTitle','off','Position',[200 100 900 600]);

ax = axes('Parent',fig,'Position',[0.38 0.15 0.58 0.75]);
xlabel(ax,'屏幕位置 x (mm)');
ylabel(ax,'归一化光强');
grid(ax,'on');

%% ================== 默认参数 ==================

params.mode = 1;           % 1-单色光  2-白光
params.lambda = 632.8;     % nm
params.lambda_min = 400;   % nm
params.lambda_max = 700;   % nm
params.L = 1.0;            % m
params.d = 0.5;            % mm
params.a = 0.05;           % mm

%% ================== 控件 ==================

% 干涉模式
uicontrol(fig,'Style','text','Position',[30 520 120 20],...
    'String','干涉模式');
modeMenu = uicontrol(fig,'Style','popupmenu','Position',[30 490 120 30],...
    'String',{'单色光','白光'});

% 单色波长
uicontrol(fig,'Style','text','Position',[30 450 120 20],...
    'String','单色波长 λ (nm)');
lambdaEdit = uicontrol(fig,'Style','edit','Position',[30 425 120 25],...
    'String','632.8');

% 白光波长范围
uicontrol(fig,'Style','text','Position',[30 380 120 20],...
    'String','白光 λ_min (nm)');
lambdaMinEdit = uicontrol(fig,'Style','edit','Position',[30 355 120 25],...
    'String','400');

uicontrol(fig,'Style','text','Position',[30 330 120 20],...
    'String','白光 λ_max (nm)');
lambdaMaxEdit = uicontrol(fig,'Style','edit','Position',[30 305 120 25],...
    'String','700');

% 屏距
uicontrol(fig,'Style','text','Position',[30 270 120 20],...
    'String','屏距 L (m)');
LEdit = uicontrol(fig,'Style','edit','Position',[30 245 120 25],...
    'String','1.0');

% 缝距
uicontrol(fig,'Style','text','Position',[30 220 120 20],...
    'String','缝距 d (mm)');
dEdit = uicontrol(fig,'Style','edit','Position',[30 195 120 25],...
    'String','0.5');

% 缝宽
uicontrol(fig,'Style','text','Position',[30 170 120 20],...
    'String','缝宽 a (mm)');
aEdit = uicontrol(fig,'Style','edit','Position',[30 145 120 25],...
    'String','0.05');

% 参数显示框
paramBox = uicontrol(fig,'Style','listbox','Position',[170 160 170 230],...
    'FontSize',10);

% 生成按钮
uicontrol(fig,'Style','pushbutton','String','生成干涉图像', ...
    'FontSize',11,'Position',[170 120 170 30], ...
    'Callback',@generatePlot);

%% ================== 回调函数 ==================

    function generatePlot(~,~)

        % 读取模式
        params.mode = get(modeMenu,'Value');

        % 读取输入参数
        params.lambda     = str2double(get(lambdaEdit,'String'));
        params.lambda_min = str2double(get(lambdaMinEdit,'String'));
        params.lambda_max = str2double(get(lambdaMaxEdit,'String'));
        params.L          = str2double(get(LEdit,'String'));
        params.d          = str2double(get(dEdit,'String'));
        params.a          = str2double(get(aEdit,'String'));

        % 合法性检查
        if any(isnan([params.lambda, params.lambda_min, ...
                      params.lambda_max, params.L, ...
                      params.d, params.a]))
            errordlg('所有参数必须输入数值','输入错误');
            return;
        end

        % 参数显示
        list = {};
        if params.mode == 1
            list{end+1} = '模式：单色光';
            list{end+1} = sprintf('λ = %.1f nm',params.lambda);
        else
            list{end+1} = '模式：白光';
            list{end+1} = sprintf('λ_min = %.1f nm',params.lambda_min);
            list{end+1} = sprintf('λ_max = %.1f nm',params.lambda_max);
        end
        list{end+1} = sprintf('L = %.2f m',params.L);
        list{end+1} = sprintf('d = %.3f mm',params.d);
        list{end+1} = sprintf('a = %.3f mm',params.a);
        set(paramBox,'String',list);

        % 计算并绘图
        x = linspace(-10e-3,10e-3,4000);
        cla(ax);

        if params.mode == 1
            lam = params.lambda * 1e-9;
            I = calcIntensity(x, lam, params);
            plot(ax, x*1e3, I, 'b', 'LineWidth', 1.2);
            title(ax, ['单色光干涉  λ = ',num2str(params.lambda,'%.1f'),' nm']);
        else
            lambda = linspace(params.lambda_min, params.lambda_max, 150) * 1e-9;
            I = zeros(size(x));
            for k = 1:length(lambda)
                I = I + calcIntensity(x, lambda(k), params);
            end
            I = I / max(I);
            plot(ax, x*1e3, I, 'k', 'LineWidth', 1.2);
            title(ax, '白光干涉');
        end

        drawnow;
    end

end

%% ================== 光强计算函数 ==================

function I = calcIntensity(x, lambda, params)

    L = params.L;
    d = params.d * 1e-3;
    a = params.a * 1e-3;

    beta = pi * a * x ./ (lambda * L);
    beta(beta == 0) = eps;
    I_diff = (sin(beta) ./ beta).^2;

    delta = pi * d * x ./ (lambda * L);
    I_int = cos(delta).^2;

    I = I_diff .* I_int;
    I = I / max(I);

end
