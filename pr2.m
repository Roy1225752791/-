%���ɴ���ͼƬģ�壬��������ģ��Ա�
TestImgPath = './test-images/';
ModelPath = './modelmat/';
EachModelPath = './eachmodelmat/';
SideNum = 28;

%����ÿ��ͼƬ��ģ��
Imgs = dir([TestImgPath '*.bmp']);
Imgnum = length(Imgs);
numnum = zeros(1,10);  %0-9������ͼƬ���� ����һ��ȫ0��10��һά����
rightnum = zeros(1,10); %0-9ʶ����ȷ��ͼƬ����
for i = 1 : Imgnum
    img = imread([TestImgPath Imgs(i).name]); %����ԭʼͼƬ
    img = imbinarize(img, graythresh(img)); %graythresh�����Զ�������ֵ��imbinarize����ͼ���ֵ��
    [x,y] = size(img); %���ͼ��ߴ�,�������ص���һ���������x���������ص��ڶ����������y
    model = zeros(SideNum,SideNum); %��ģ�ʹ�С�ֳ�14*14�����񣬼�ÿ����������Ϊ2*2
    for m = 1:SideNum               %������ָ�
        for n = 1:SideNum
        x_start = 1+(m-1)*fix(x/SideNum);  %fix(x)������x��Ԫ���㷽��ȡ�����õ�һ����������
        x_end = m*fix(x/SideNum);
        y_start = 1+(n-1)*fix(y/SideNum);
        y_end = n*fix(y/SideNum);
        rect = img(x_start:x_end,y_start:y_end); %��ÿ��������,rectΪ���г�����ÿ��С����
        model(m,n) = sum(sum(rect)); %sum()��������ͣ��ڶ������������
        w = model(m,n);
        b = 4-w;
        p = b/4;
        %disp(['��ɫ���ص����:',num2str(b),'�ٷֱ�:',num2str(p)]);
        end
    end
    ModelList = dir([EachModelPath '*.mat']); %ѵ����ģ���ļ��б�
    Modelnum = length(ModelList); %ģ���ļ�����
    minlen = Inf; %Inf��ʾ�����
    suitmodel = ''; %�Ƚ�����ʵ�ģ�͸�ֵΪ��
    for j = 1:Modelnum
        modeltrain = open([EachModelPath ModelList(j).name]); %��ѵ���õ�ģ�;���
        c = (modeltrain.model - model).^2; %��ŷ�Ͼ��룬�����˷�
        len = sqrt(sum(sum(c()))); %��ŷ�Ͼ��룬�����󿪷�
        if len < minlen    %����̵�ŷ�Ͼ��뼴��Ϊ����ʵ�ģ��
            minlen = len;
            suitmodel = ModelList(j).name;
        end
    end
    disp(['��',num2str(i),'��ͼƬ���֣�', suitmodel(1)]);
    number = Imgs(i).name(1); %ͼƬ���Ƶĵ�һ���ַ�
    numnum(str2num(number)+1) = numnum(str2num(number)+1)+1;%�ܸ��������е�i+1��Ԫ��ֵ��1
    if number == suitmodel(1)                               %���ͼƬ���Ƶĵ�һ���ַ����ҵ�����ʵ�ģ�͵�һ���ַ����
        rightnum(str2num(number)+1) = rightnum(str2num(number)+1)+1; %��ȷ���������е�i+1��Ԫ��ֵ��1
    end
    disp(['��ȷƥ����:',num2str(rightnum(str2num(number)+1)),'����:',num2str(numnum(str2num(number)+1))]);
end
precision = rightnum./numnum; %0-9ÿ�����־�ȷ��
allprecision = sum(precision)/10; %�ܾ�ȷ��
for i=1:10
    disp(['����',num2str(i-1), 'ƥ�侫׼��:', num2str(precision(i))]);
end
disp(['�ܾ�׼�ȣ�', num2str(allprecision)]);
