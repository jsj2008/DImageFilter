//
//  GLImageOperate.m
//  DImageFilter
//
//  Created by tony on 6/9/16.
//  Copyright © 2016 sjtu. All rights reserved.
//

#import "GLImageOperate.h"

@implementation GLImageOperate

/**
 *  改变突变对比度与亮度
 *
 *  @param srcMat 原图Mat
 *  @param alpha  对比度
 *  @param beta   亮度 1~100之间
 */
+ (Mat)adjustMat:(Mat)srcMat contrast:(float)alpha Bright:(float)beta{
    Mat dstMat = Mat(srcMat.size(), srcMat.type());
    
    int rows = srcMat.rows, cols = srcMat.cols;
    for (int x=0; x < rows; x++) {
        for (int y=0; y < cols; y++) {
            for (int z = 0; z < 3; z++) {
                dstMat.at<Vec3b>(y,x)[z] = saturate_cast<uchar>(alpha * (srcMat.at<Vec3b>(y,x)[z]) + beta);
            }
        }
    }
    
    return dstMat;
}

#pragma mark — ——  代数操作  —— —
+ (Mat)addMatFirst:(Mat)src1 second:(Mat)src2{
    Mat dstMat;
    add(src1, src2, dstMat);
    
    return dstMat;
}

+ (Mat)MatAddValue:(int)value Mat:(Mat)srcMat{
    int cols = srcMat.cols;
    int rows = srcMat.rows;
    
    Mat dstMat;
    for (int i = 0; i < rows; i++) {
        
        for (int j=0; j< cols; j++) {
            
        }
    }
    
    return dstMat;
}

#pragma mark —————————————

#pragma mark — — 对比度调整 — —



#pragma mark —————————————


#pragma mark — — 图像变换操作 — —
/**
 *  图像大小变换
 *
 *  @param srcMat 原图矩阵
 *  @param type   图像插值类型，0——最近邻插值， 1——双线性插值， 2——立方插值
 */
+ (Mat)cvReSize:(Mat)srcMat interType:(int)type{
    Mat dstMat;
    /**
     *  interpolation
     插值方法:
     CV_INTER_NN - 最近邻插值,
     CV_INTER_LINEAR - 双线性插值 (缺省使用)
     CV_INTER_AREA - 使用象素关系重采样。当图像缩小时候，该方法可以避免波纹出现。当图像放大时，类似于 CV_INTER_NN 方法..
     CV_INTER_CUBIC - 立方插值.
     */
    cvResize(&srcMat, &dstMat, type);
    
    return dstMat;
}

/**
 *  矩阵平移， 原图像不变
 *
 *  @param srcMat 原矩阵
 *  @param dx     X方向平移
 *  @param dy     Y方向平移
 */
+ (Mat)translateTransform:(Mat)srcMat X:(int)dx Y:(int)dy{
    
//    CV_ASSERT(srcMat.depth() == CV_8U);
    
    Mat dstMat;
    const int rows = srcMat.rows;
    const int cols = srcMat.cols;
    dstMat.create(rows, cols, srcMat.type());
    
    Vec3b *p;
    for (int i=0; i< rows; i++) {
        p = dstMat.ptr<Vec3b>(i);
        for (int j=0; j < cols; j++) {
            //平移后坐标映射到原图像
            int x = j - dx;
            int y = i - dy;
            //保证映射后的坐标在原图像范围内
            if (x >= 0 && y >= 0 && x < cols && y < rows)
                p[j] = srcMat.ptr<Vec3b>(y)[x];
        }
    }
    
    return dstMat;
}

//平移后图像的大小变化
+ (Mat)translateSizeChangeTransform:(Mat)srcMat X:(int)dx Y:(int)dy{
    Mat dstMat;
    const int rows = srcMat.rows + abs(dy);;
    const int cols = srcMat.cols + abs(dx);
    
    dstMat.create(rows, cols, srcMat.type());
    
    Vec3b *p;
    for (int i=0; i< rows; i++) {
        p = dstMat.ptr<Vec3b>(i);
        for (int j=0; j < cols; j++) {
            //平移后坐标映射到原图像
            int x = j - dx;
            int y = i - dy;
            
            //保证映射后的坐标在原图像范围内
            if (x >= 0 && y >= 0 && x < cols && y < rows)
                p[j] = srcMat.ptr<Vec3b>(y)[x];
        }
    }
    
    return dstMat;
}


/**
 * 水平镜像, 在水平镜像变换时，遍历了整个图像，然后根据映射关系对每个像素都做了处理。
 * 实际上，水平镜像变换就是将图像坐标的列换到右边，右边的列换到左边，是可以以列为单位做变换的。同样垂直镜像变换也如此，可以以行为单位进行变换。
 *
 *  @param srcMat 原图像矩阵
 *
 *  @return 处理后的矩阵
 */
+ (Mat)mirrorHTransmit:(Mat)srcMat{
    Mat dstMat;
    dstMat.create(srcMat.rows, srcMat.cols, srcMat.type());
    
    int rows = srcMat.rows;
    int cols = srcMat.cols;
    
    switch (srcMat.channels()) {
        case 1:
            {
                const uchar *origal;
                uchar *p;
                for (int i = 0; i < rows; i++){
                    origal = srcMat.ptr<uchar>(i);
                    p = dstMat.ptr<uchar>(i);
                    for (int j = 0; j < cols; j++){
                        p[j] = origal[cols - 1 - j];
                    }
                }
            }
            break;
        case 3:
            {
                const Vec3b *origal3;
                Vec3b *p3;
                for (int i = 0; i < rows; i++) {
                    origal3 = srcMat.ptr<Vec3b>(i);
                    p3 = dstMat.ptr<Vec3b>(i);
                    for(int j = 0; j < cols; j++){
                        p3[j] = origal3[cols - 1 - j];
                    }
                }
            }
            break;
        default:
            break;
    }
    
    return dstMat;
}

/**
 *  垂直镜像处理
 */
+ (Mat)mirrorVTransmit:(Mat)srcMat{
    Mat dstMat;
    dstMat.create(srcMat.rows, srcMat.cols, srcMat.type());
    
    int rows = srcMat.rows;
    for (int i=0; i < rows; i++) {
        srcMat.row(rows -i -1).copyTo(dstMat.row(i));   //从原图像中取出第i行，并将其复制到目标图像。
    }
    
    return dstMat;
}

//图像旋转变换（原尺寸）
+ (IplImage *)rotateImageWithSrcImage:(IplImage *)srcImg degree:(int)degree{
    //旋转中心为图像中心
    CvPoint2D32f center;
    center.x = float(srcImg->width/2.0+0.5);
    center.y = float(srcImg->height/2.0+0.5);
    
    IplImage *dstImg;
    
    //计算二维旋转的仿射变换矩阵
    float m[6];
    CvMat M = cvMat(2, 3, CV_32F, m);
    cv2DRotationMatrix(center, degree,1, &M);
    
    
    
    cvWarpAffine(srcImg,dstImg, &M);    //变换图像，并用默认色填充其余值
//    cvWarpAffine(srcImg,dstImg, &M, CV_INTER_LINEAR+CV_WARP_FILL_OUTLIERS, cvScalarAll(0));   //变换图像，并用黑色填充其余值

    return dstImg;
}


//旋转图像内容不变，尺寸相应变大
IplImage* rotateImage2(IplImage* img, int degree)
{
    double angle = degree  * CV_PI / 180.;
    double a = sin(angle), b = cos(angle);
    int width=img->width, height=img->height;
    //旋转后的新图尺寸
    int width_rotate= int(height * fabs(a) + width * fabs(b));
    int height_rotate=int(width * fabs(a) + height * fabs(b));
    IplImage* img_rotate = cvCreateImage(cvSize(width_rotate, height_rotate), img->depth, img->nChannels);
    cvZero(img_rotate);
    //保证原图可以任意角度旋转的最小尺寸
    int tempLength = sqrt((double)width * width + (double)height *height) + 10;
    int tempX = (tempLength + 1) / 2 - width / 2;
    int tempY = (tempLength + 1) / 2 - height / 2;
    IplImage* temp = cvCreateImage(cvSize(tempLength, tempLength), img->depth, img->nChannels);
    cvZero(temp);
    //将原图复制到临时图像tmp中心
    cvSetImageROI(temp, cvRect(tempX, tempY, width, height));
    cvCopy(img, temp, NULL);
    cvResetImageROI(temp);
    //旋转数组map
    // [ m0  m1  m2 ] ===>  [ A11  A12   b1 ]
    // [ m3  m4  m5 ] ===>  [ A21  A22   b2 ]
    float m[6];
    int w = temp->width;
    int h = temp->height;
    m[0] = b;
    m[1] = a;
    m[3] = -m[1];
    m[4] = m[0];
    // 将旋转中心移至图像中间
    m[2] = w * 0.5f;
    m[5] = h * 0.5f;
    CvMat M = cvMat(2, 3, CV_32F, m);
    cvGetQuadrangleSubPix(temp, img_rotate, &M);
    cvReleaseImage(&temp);
    return img_rotate;
}

#pragma mark -------------阈值算法----------------
/**
 *  大津法取阈值
 *
 *  @param pImageData 图像数据
 *  @param nWidth     图像宽度
 *  @param nHeight    图像高度
 *  @param nWidthStep 图像行大小
 *
 *  @return 阈值
 */
int  OTSU(unsigned char* pGrayImg , int iWidth , int iHeight)
{
    if((pGrayImg==0)||(iWidth<=0)||(iHeight<=0))return -1;
    int ihist[256];
    int thresholdValue=0; // „–÷µ
    int n, n1, n2 ;
    double m1, m2, sum, csum, fmax, sb;
    int i,j,k;
    memset(ihist, 0, sizeof(ihist));
    n=iHeight*iWidth;
    sum = csum = 0.0;
    fmax = -1.0;
    n1 = 0;
    for(i=0; i < iHeight; i++)
    {
        for(j=0; j < iWidth; j++)
        {
            ihist[*pGrayImg]++;
            pGrayImg++;
        }
    }
    pGrayImg -= n;
    for (k=0; k <= 255; k++)
    {
        sum += (double) k * (double) ihist[k];
    }
    for (k=0; k <=255; k++)
    {
        n1 += ihist[k];
        if(n1==0)continue;
        n2 = n - n1;
        if(n2==0)break;
        csum += (double)k *ihist[k];
        m1 = csum/n1;
        m2 = (sum-csum)/n2;
        sb = (double) n1 *(double) n2 *(m1 - m2) * (m1 - m2);
        if (sb > fmax)
        {
            fmax = sb;
            thresholdValue = k;
        }
    }
    return(thresholdValue);
}
@end

/*==================================================================
 =  代码内容：最大熵阈值分割
 =  修改日期:2009-3-3
 =  作者:crond123
 =  博客:http://blog.csdn.net/crond123/
 =   E_Mail:crond123@163.com
 =  修改：jink2005
 =  论坛：http://www.aiseminar.com/bbs
 ====================================================================*/
int HistogramBins = 256;
float HistogramRange1[2] = {0,255};
float *HistogramRange[1] = {&HistogramRange1[0]};
typedef enum {back,object} entropy_state;
// 计算当前位置的能量熵
double caculateCurrentEntropy(CvHistogram * Histogram1, int cur_threshold, entropy_state state)
{
    int start,end;
    if(state == back)
    {
        start = 0;
        end = cur_threshold;
    }
    else
    {
        start = cur_threshold;
        end = 256;
    }
    int  total = 0;
    for(int i = start; i < end; i++)
    {
//        total += (int)cvQueryHistValue_1D(Histogram1, i);
    }
    double cur_entropy = 0.0;
    for(i = start; i < end; i++)
    {
        if((int)cvQueryHistValue_1D(Histogram1,i) == 0)
            continue;
        double percentage = cvQueryHistValue_1D(Histogram1, i) / total;
        cur_entropy += - percentage * logf(percentage); // 能量的定义公式
    }
    return cur_entropy;
}
// 寻找最大熵阈值并分割
void MaxEntropy(IplImage *src, IplImage *dst)
{
    assert(src != NULL);
    assert(src->depth == 8 && dst->depth == 8);
    assert(src->nChannels == 1);
    CvHistogram * hist  = cvCreateHist(1, &HistogramBins, CV_HIST_ARRAY, HistogramRange);
    cvCalcHist(&src, hist);
    double maxentropy = -1.0;
    int max_index = -1;
    // 循环测试每个分割点，寻找到最大的阈值分割点
    for(int i = 0; i < HistogramBins; i++)
    {
        double cur_entropy = caculateCurrentEntropy(hist, i, object) + caculateCurrentEntropy(hist, i, back);
        if(cur_entropy > maxentropy)
        {
            maxentropy = cur_entropy;
            max_index = i;
        }
    }
    cvThreshold(src, dst, (double)max_index, 255, CV_THRESH_BINARY);
    cvReleaseHist(&hist);
}


@implementation GLImageOperate (BaseOparetion)

+ (Mat)binaryzation:(Mat)srcMat{
    /*
     openCV二值化过程：
     1.Src的UIImage ->  Src的IplImage
     2.设置Src的IplImage的ImageROI
     3.创建新的dstImage1的IplImage，并复制Src的IplImage
     
     4.dstImage1的IplImage转换成cvMat形式的matImage
     */
    cv::Mat matImage = srcMat;
    cv::Mat greymat;
    
    //5.cvtColor函数对matImage进行灰度处理, 取得IplImage形式的灰度图像
    cv::cvtColor(srcMat, greymat, CV_BGR2GRAY); //转换成灰色
    
    //6.使用灰度后的IplImage形式图像，用OSTU算法算阈值：threshold
    IplImage grey = greymat;
    unsigned char* dataImage = (unsigned char*)grey.imageData;
    int threshold = OTSU(dataImage, grey.width, grey.height);
    printf("阈值：%d\n",threshold);
    
    return [[self class] binaryzation:srcMat threshValue:threshold];
}

+ (Mat)binaryzation:(Mat)srcMat threshValue:(int)value{
    if (value < 0)  value = 0;
    if (value > 250)    value = 250;
    
    /*
     openCV二值化过程：
     1.Src的UIImage ->  Src的IplImage
     2.设置Src的IplImage的ImageROI
     3.创建新的dstImage1的IplImage，并复制Src的IplImage
     
     4.dstImage1的IplImage转换成cvMat形式的matImage
     */
    cv::Mat matImage = srcMat;
    cv::Mat greymat;
    
    //5.cvtColor函数对matImage进行灰度处理, 取得IplImage形式的灰度图像
    cv::cvtColor(matImage, greymat, CV_BGR2GRAY); //转换成灰色
    
    //7.利用阈值算得新的cvMat形式的图像
    cv::Mat matBinary;
    cv::threshold(greymat, matBinary, value, 255, cv::THRESH_BINARY);
    
    return matBinary;
}

@end

//roberts算子求图像梯度提取边缘，输入源图像，输出梯度图，此方法不常用

//如果源图像是8位的，为避免溢出，目标图像深度必须是16S，或32位

//prewitt算子，模板卷积公式编写，常用方法

//Kirsch算子,根据方向的对称性，可以只对前面4个模板进行处理，求最大值。采用求中心像素周围像素梯度，此方法是最好用的方法。


@implementation GLImageOperate (edgeDetection)
/**
 *  计算输入图像的所有非零元素对其最近零元素的距离
 *
 *  @param srcMat 原图像元素
 */
+ (Mat)distanceTransform:(Mat)srcMat{
    Mat dstMat;
    
    /**
     *  计算输入图像的所有非零元素对其最近零元素的距离
     *  src：輸入圖，8位元單通道(通常為二值化圖)。
     *  dst：輸出圖，32位元單通道浮點數圖，和src的尺寸相同。
     *  distanceType：距離型態，可以選擇CV_DIST_L1、CV_DIST_L2或CV_DIST_C。
     *  maskSize：遮罩尺寸，可以選3、5或CV_DIST_MASK_PRECISE，當 distanceType為CV_DIST_L1或CV_DIST_C，這個參數限制為3(因為3和5的結果相同)。
     */
    distanceTransform(srcMat, dstMat, CV_DIST_L1, 5);
    return dstMat;
}

+ (Mat)prewitt:(Mat)src{
    Mat gray,Kernelx,Kernely;
    
    cvtColor(src, gray, CV_RGB2GRAY);
    
    Kernelx = (Mat_<double>(3,3) << 1, 1, 1, 0, 0, 0, -1, -1, -1);
    Kernely = (Mat_<double>(3,3) << -1, 0, 1, -1, 0, 1, -1, 0, 1);
    
    Mat grad_x, grad_y;
    Mat abs_grad_x, abs_grad_y, grad;
    
    filter2D(gray, grad_x, CV_16S , Kernelx, cv::Point(-1,-1));
    filter2D(gray, grad_y, CV_16S , Kernely, cv::Point(-1,-1));
    convertScaleAbs( grad_x, abs_grad_x );
    convertScaleAbs( grad_y, abs_grad_y );
    
    addWeighted( abs_grad_x, 0.5, abs_grad_y, 0.5, 0, grad );
    
    return grad;
}


+ (Mat)roberts:(Mat)src{
    int pixel[4] = {0};
    int rows = src.rows - 1;
    int cols = src.cols - 1;
    
    Mat dst;
    src.copyTo(dst);
    
    //M(x,y) = 根号[(z9-z5)平方+（z8-z6)平方]
    for (int i=0; i<rows; i++) {
        for (int j=0; j<cols; j++) {
            pixel[0] = src.at<uchar>(i,j);
            pixel[1] = src.at<uchar>(i+1,j);
            pixel[2] = src.at<uchar>(i,j+1);
            pixel[3] = src.at<uchar>(i+1,j+1);
            
            dst.at<uchar>(i,j) = sqrt(double((pixel[0] - pixel[3])*(pixel[0] - pixel[3]) + (pixel[1] - pixel[2])*(pixel[1] - pixel[2])));
        }
    }
    
    return dst;
}

@end