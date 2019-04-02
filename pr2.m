%生成待测图片模板，并和所有模板对比
TestImgPath = './test-images/';
ModelPath = './modelmat/';
EachModelPath = './eachmodelmat/';
SideNum = 28;

%生成每张图片的模板
Imgs = dir([TestImgPath '*.bmp']);
Imgnum = length(Imgs);
numnum = zeros(1,10);  %0-9各数字图片数量 创建一个全0的10长一维数组
rightnum = zeros(1,10); %0-9识别正确的图片数量
for i = 1 : Imgnum
    img = imread([TestImgPath Imgs(i).name]); %读入原始图片
    img = imbinarize(img, graythresh(img)); %graythresh（）自动生成阈值，imbinarize（）图像二值化
    [x,y] = size(img); %获得图像尺寸,行数返回到第一个输出变量x，列数返回到第二个输出变量y
    model = zeros(SideNum,SideNum); %将模型大小分成14*14的网格，即每个网格像素为2*2
    for m = 1:SideNum               %等区间分割
        for n = 1:SideNum
        x_start = 1+(m-1)*fix(x/SideNum);  %fix(x)函数将x中元素零方向取整，得到一个整数数组
        x_end = m*fix(x/SideNum);
        y_start = 1+(n-1)*fix(y/SideNum);
        y_end = n*fix(y/SideNum);
        rect = img(x_start:x_end,y_start:y_end); %将每块读入矩阵,rect为剪切出来的每个小矩形
        model(m,n) = sum(sum(rect)); %sum()矩阵按列求和，第二次行向量求和
        w = model(m,n);
        b = 4-w;
        p = b/4;
        %disp(['黑色像素点个数:',num2str(b),'百分比:',num2str(p)]);
        end
    end
    ModelList = dir([EachModelPath '*.mat']); %训练的模型文件列表
    Modelnum = length(ModelList); %模型文件长度
    minlen = Inf; %Inf表示无穷大
    suitmodel = ''; %先将最合适的模型赋值为空
    for j = 1:Modelnum
        modeltrain = open([EachModelPath ModelList(j).name]); %打开训练好的模型矩阵
        c = (modeltrain.model - model).^2; %求欧氏距离，矩阵点乘法
        len = sqrt(sum(sum(c()))); %求欧氏距离，将矩阵开方
        if len < minlen    %求最短的欧氏距离即视为最合适的模型
            minlen = len;
            suitmodel = ModelList(j).name;
        end
    end
    disp(['第',num2str(i),'张图片数字：', suitmodel(1)]);
    number = Imgs(i).name(1); %图片名称的第一个字符
    numnum(str2num(number)+1) = numnum(str2num(number)+1)+1;%总个数数组中第i+1个元素值加1
    if number == suitmodel(1)                               %如果图片名称的第一个字符与找到最合适的模型第一个字符相等
        rightnum(str2num(number)+1) = rightnum(str2num(number)+1)+1; %正确个数数组中第i+1个元素值加1
    end
    disp(['正确匹配数:',num2str(rightnum(str2num(number)+1)),'总数:',num2str(numnum(str2num(number)+1))]);
end
precision = rightnum./numnum; %0-9每个数字精确度
allprecision = sum(precision)/10; %总精确度
for i=1:10
    disp(['数字',num2str(i-1), '匹配精准度:', num2str(precision(i))]);
end
disp(['总精准度：', num2str(allprecision)]);
