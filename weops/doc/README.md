## 嘉为蓝鲸greenplum数据库监控插件使用说明

### 插件功能

采集器连接数据库后执行sql，转换为监控指标。  

### 版本支持：

操作系统支持: linux, windows  

是否支持arm: 支持  

**组件支持版本：**

greenplum数据库: v5.x、v6.x  

部分指标采集逻辑依据版本v5.x和v6.x有所不同  

### 使用指引

登录数据库并执行命令创建蓝鲸监控账号和授权：

 ```bash
# 创建用户: weops 密码: Weops123!
psql --username gp --dbname postgres
CREATE USER weops WITH PASSWORD 'Weops123!';
CREATE DATABASE weopsdb WITH OWNER weops;
 ```


注意: 
1. 如果有database_size_scraper相关指标采集报错  
    需要注意是否能在指定数据库名下进行对应的sql查询，一般该类指标只能在默认数据库名(postgres)下采集。该处提到的数据库名对应参数SQL_EXPORTER_DB_NAME。
  
2. 如果有 `permission denied for relation gp_disk_free`报错    
    主要影响采集指标 `剩余磁盘空间`
   **需要检查是否有对gp_disk_free表的查询权限。**   

    1) 权限的查询结果
    ```
    postgres=# SHOW search_path;
      search_path   
    ----------------
     "$user",public
    (1 row)
    ```
    
    2) 永久性设置 search_path  
    如果希望永久修改用户 weops 的 search_path，可以更新用户的默认设置。以超级用户身份运行以下命令：   
   `ALTER USER weops SET search_path TO gp_toolkit, public;`
 
    3) 授予权限 
    在更新 search_path 设置之后，确保用户 weops 仍然有足够的权限访问 gp_disk_free 视图。以超级用户（如 gpadmin）身份登录并授予权限：  
   `GRANT SELECT ON gp_toolkit.gp_disk_free TO weops;`


### 参数说明

| **参数名**              | **含义**                    | **是否必填** | **使用举例**  |
|----------------------|---------------------------|----------|-----------|
| SQL_EXPORTER_USER    | 数据库用户名(环境变量)，特殊字符不需要编码转义  | 是        | weops     |
| SQL_EXPORTER_PASS    | 数据库密码(环境变量)，特殊字符不需要编码转义   | 是        | Weops123! |
| SQL_EXPORTER_HOST    | 数据库服务IP(环境变量)             | 是        | 127.0.0.1 |
| SQL_EXPORTER_PORT    | 数据库服务端口(环境变量)             | 是        | 5236      |
| SQL_EXPORTER_DB_NAME | 数据库名(环境变量)，建议使用默认postgres | 是        | postgres  |
| --log.level          | 日志级别                      | 否        | info      |


### 指标列表
| **指标ID**                                                 | **指标中文名** | **维度ID**                                                                  | **维度含义**                                    | **单位**  |
|----------------------------------------------------------|-----------|---------------------------------------------------------------------------|---------------------------------------------|---------|
| greenplum_up                                             | 监控插件运行状态  | -                                                                         | -                                           | -       |
| greenplum_cluster_state                                  | 集群状态      | version, master, standby                                                  | 版本, master主机名, standby主机名                   | -       |
| greenplum_cluster_uptime                                 | 集群运行时间    | -                                                                         | -                                           | s       |
| greenplum_cluster_sync                                   | 集群同步状态    | -                                                                         | -                                           | -       |
| greenplum_cluster_max_connections                        | 最大连接数     | -                                                                         | -                                           | -       |
| greenplum_cluster_total_connections                      | 当前连接数     | -                                                                         | -                                           | -       |
| greenplum_cluster_idle_connections                       | 空闲连接数     | -                                                                         | -                                           | -       |
| greenplum_cluster_active_connections                     | 活动连接数     | -                                                                         | -                                           | -       |
| greenplum_cluster_running_connections                    | 运行中连接数    | -                                                                         | -                                           | -       |
| greenplum_cluster_waiting_connections                    | 等待中连接数    | -                                                                         | -                                           | -       |
| greenplum_node_segment_status                            | Segment状态 | hostname, address, dbid, content, preferred_role, port                    | 主机名, 地址, 数据库ID, 内容, 首选角色, 端口                | -       |
| greenplum_node_segment_role                              | Segment角色 | hostname, address, dbid, content, preferred_role, port                    | 主机名, 地址, 数据库ID, 内容, 首选角色, 端口                | -       |
| greenplum_node_segment_mode                              | Segment模式 | hostname, address, dbid, content, preferred_role, port                    | 主机名, 地址, 数据库ID, 内容, 首选角色, 端口                | -       |
| greenplum_node_segment_disk_free_mb_size                 | 剩余磁盘空间    | hostname                                                                  | 主机名                                         | mb      |
| greenplum_cluster_total_connections_per_client           | 每客户端总连接数  | client                                                                    | 客户端名                                        | -       |
| greenplum_cluster_idle_connections_per_client            | 每客户端空闲连接数 | client                                                                    | 客户端名                                        | -       |
| greenplum_cluster_active_connections_per_client          | 每客户端活动连接数 | client                                                                    | 客户端名                                        | -       |
| greenplum_cluster_total_online_user_count                | 在线用户数     | -                                                                         | -                                           | -       |
| greenplum_cluster_total_client_count                     | 客户端总数     | -                                                                         | -                                           | -       |
| greenplum_cluster_total_connections_per_user             | 每用户总连接数   | usename                                                                   | 用户名                                         | -       |
| greenplum_cluster_idle_connections_per_user              | 每用户空闲连接数  | usename                                                                   | 用户名                                         | -       |
| greenplum_cluster_active_connections_per_user            | 每用户活动连接数  | usename                                                                   | 用户名                                         | -       |
| greenplum_cluster_config_last_load_time_seconds          | 配置加载时间    | -                                                                         | -                                           | s       |
| greenplum_node_database_name_gb_size                     | 数据库存储空间   | dbname                                                                    | 数据库名                                        | gb      |
| greenplum_node_database_table_total_count                | 数据库内表总数量  | dbname                                                                    | 数据库名                                        | -       |
| greenplum_server_locks_table_detail                      | 锁表详情      | pid,datname,usename,locktype,mode,application_name,state,lock_satus,query | 进程id, 数据库名, 用户名, 锁类型, 模式, 应用名称, 状态, 锁状态, 查询 | -       |
| greenplum_server_database_hit_cache_percent_rate         | 缓存命中率     | -                                                                         | -                                           | percent |
| greenplum_server_database_transition_commit_percent_rate | 事务提交率     | -                                                                         | -                                           | percent |
| greenplum_exporter_total_scraped                         | 导出器抓取总数   | -                                                                         | -                                           | -       |
| greenplum_exporter_total_error                           | 导出错误总数    | -                                                                         | -                                           | -       |
| greenplum_exporter_scrape_duration_second                | 抓取持续时间    | -                                                                         | -                                           | s       |


### 版本日志

#### weops_greenplum_exporter 2.5.1
- weops调整

