---
title: TLE两行根数简介及获取方法
date: 2025-05-17 14:10:18
categories: GIS
tags: [TLE]
---

# TLE简介

TLE(Two-line element set, TLE)是用于描述卫星轨道的参数，是一种轨道编码方式，用于确定给定历元时刻下，绕地运行空间目标的轨道根数。

使用合适的预测模型，可以以一定精度估计出目标在轨道上任意一点的位置和速度。

TLE轨道根数对应的计算模型是简化普适模型（simplified perturbations models,包括SGP, SGP4, SDP4, SGP8 and SDP8），因此，任何使用TLE数据的算法必须使用一种简化普适模型来准确计算出轨道的参数。

# TLE获取方法

1. 数据下载网站
   [NORAD GP Element Sets Current Data](https://celestrak.org/NORAD/elements/)
2. 网络API
   [N2YO.COM REST API v1](https://www.n2yo.com/api/#api-pass)

# TLE数据格式

## 标题行（可选）

[Tle_title](/img/TLE两行根数简介及获取方法/Tle_title.jpg)

| 序号 | 位数  |      内容      |    例子     |
| :--: | :---: | :------------: | :---------: |
|  1   | 01–24 | Satellite name | ISS (ZARYA) |

如果存在，TLE 是一个三行元素集（ 3LE ）。
如果不存在，则 TLE 是一个两行元素集（ 2LE ）。

## 第一行（必需）

[Tle_first_row](/img/TLE两行根数简介及获取方法/Tle_first_row.jpg)

| 序号 | 位数  |                                     内容                                      |    例子     |
| :--: | :---: | :---------------------------------------------------------------------------: | :---------: |
|  1   |  01   |                                  Line number                                  |      1      |
|  2   | 03–07 |                           Satellite catalog number                            |    25544    |
|  3   |  08   |          Classification (U: unclassified, C: classified, S: secret)           |      U      |
|  4   | 10–11 |           International Designator (last two digits of launch year)           |     98      |
|  5   | 12–14 |             International Designator (launch number of the year)              |     067     |
|  6   | 15–17 |                International Designator (piece of the launch)                 |      A      |
|  7   | 19–20 |                     Epoch year (last two digits of year)                      |     08      |
|  8   | 21–32 |           Epoch (day of the year and fractional portion of the day)           | 64.51782528 |
|  9   | 34–43 |          First derivative of mean motion; the ballistic coefficient           | -.00002182  |
|  10  | 45–52 |           Second derivative of mean motion (decimal point assumed)            |   00000-0   |
|  11  | 54–61 | B\*, the drag term, or radiation pressure coefficient (decimal point assumed) |  -11606-4   |
|  12  |  63   |       Ephemeris type (always zero; only used in undistributed TLE data)       |      0      |
|  13  | 65–68 | Element set number. Incremented when a new TLE is generated for this object.  |     292     |
|  14  |  69   |                             Checksum (modulo 10)                              |      7      |

## 第二行（必需）

[Tle_second_row](/img/TLE两行根数简介及获取方法/Tle_second_row.jpg)

| 序号 | 位数  |                      内容                       |    例子     |
| :--: | :---: | :---------------------------------------------: | :---------: |
|  1   |  01   |                   Line number                   |      2      |
|  2   | 03–07 |            Satellite Catalog number             |    25544    |
|  3   | 09–16 |              Inclination (degrees)              |   51.6416   |
|  4   | 18–25 | Right ascension of the ascending node (degrees) |  247.4627   |
|  5   | 27–33 |      Eccentricity (decimal point assumed)       |   0006703   |
|  6   | 35–42 |          Argument of perigee (degrees)          |  130.5360   |
|  7   | 44–51 |             Mean anomaly (degrees)              |  325.0288   |
|  8   | 53–63 |        Mean motion (revolutions per day)        | 15.72125391 |
|  9   | 64–68 |    Revolution number at epoch (revolutions)     |    56353    |
|  10  |  69   |              Checksum (modulo 10)               |      7      |

# 参考链接

[维基百科](https://en.wikipedia.org/wiki/Two-line_element_set)
