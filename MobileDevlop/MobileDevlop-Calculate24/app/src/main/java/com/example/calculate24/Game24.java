package com.example.calculate24;

import java.util.ArrayList;
import java.util.List;

public class Game24 {
    public static List<String> getResultList(int a, int b, int c, int d){
        List<String> _List = new ArrayList<String>();
        int op1,op2,op3;
        //针对每一种类型表达式（总共5种），枚举所有可能的排列组合方式
        for(op1=1;op1<=4;op1++)
            for(op2=1;op2<=4;op2++)
                for(op3=1;op3<=4;op3++){
                    if(calculate_model1(a,b,c,d,op1,op2,op3)==24){
                        String s1="(("+a+showFuHao(op1)+b+")"+showFuHao(op2)+c+")"+showFuHao(op3)+d;
                        _List.add(s1);
                    }
                    if(calculate_model2(a,b,c,d,op1,op2,op3)==24){
                        String s2="("+a+showFuHao(op1)+"("+b+showFuHao(op2)+c+")"+")"+showFuHao(op3)+d;
                        _List.add(s2);
                    }
                    if(calculate_model3(a,b,c,d,op1,op2,op3)==24){
                        String s3 = a+showFuHao(op1)+"("+b+showFuHao(op2)+"("+c+showFuHao(op3)+d+"))";
                        _List.add(s3);
                    }
                    if(calculate_model4(a,b,c,d,op1,op2,op3)==24){
                        String s4 = a+showFuHao(op1)+"(("+b+showFuHao(op2)+c+")"+showFuHao(op3)+d+")";
                        _List.add(s4);
                    }
                    if(calculate_model5(a,b,c,d,op1,op2,op3)==24){
                        String s5 = "("+a+showFuHao(op1)+b+")"+showFuHao(op2)+"("+c+showFuHao(op3)+d+")";
                        _List.add(s5);
                    }
                }
        return _List;
    }

    private static String showFuHao(int op){
        switch(op){
            case 1:return "+";
            case 2:return "-";
            case 3:return "*";
            case 4:return "/";
        }
        return "";
    }

    private static float calculate_model1(float i,float j,float k,
                                          float t,int op1,int op2,int op3){

        float r1,r2,r3;                                           /*对应表达式类型：((A□B)□C)□D*/
        r1 = cal(i,j,op1);
        r2 = cal(r1,k,op2);
        r3 = cal(r2,t,op3);
        return r3;
    }

    private static float calculate_model2(float i,float j,float k,
                                          float t,int op1,int op2,int op3){
        float r1,r2,r3;                                         /*对应表达式类型：(A□(B□C))□D */
        r1 = cal(j,k,op2);
        r2 = cal(i,r1,op1);
        r3 = cal(r2,t,op3);
        return r3;
    }

    private static float calculate_model3(float i,float j,float k,
                                          float t,int op1,int op2,int op3){
        float r1,r2,r3;                                     /*对应表达式类型：A□(B□(C□D))*/
        r1 = cal(k,t,op3);
        r2 = cal(j,r1,op2);
        r3 = cal(i,r2,op1);
        return r3;
    }

    private static float calculate_model4(float i,float j,float k,
                                          float t,int op1,int op2,int op3){
        float r1,r2,r3;                                         /*对应表达式类型：A□((B□C)□D)*/
        r1 = cal(j,k,op2);
        r2 = cal(r1,t,op3);
        r3 = cal(i,r2,op1);
        return r3;
    }

    private static float calculate_model5(float i,float j,float k,
                                          float t,int op1,int op2,int op3){
        float r1,r2,r3;                                            /*对应表达式类型：(A□B)□(C□D)*/
        r1 = cal(i,j,op1);
        r2 = cal(k,t,op3);
        r3 = cal(r1,r2,op2);
        return r3;
    }

    private static  float cal(float x,float y,int op){             //计算两个操作数
        switch(op){
            case 1:return x+y;
            case 2:return x-y;
            case 3:return x*y;
            case 4:return x/y;
        }
        return 0;
    }
}
