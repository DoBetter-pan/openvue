1、账号表

CREATE TABLE `account` (
    `id` BIGINT(20) NOT NULL AUTO_INCREMENT COMMENT '账号ID',
    `user_id` BIGINT(20) NULL DEFAULT 0 COMMENT '用户ID',
    `open_code` VARCHAR(255) NULL DEFAULT '' COMMENT '登录账号，如手机号',
    `category` TINYINT(1) NULL DEFAULT 0 COMMENT '账号类别',
    `created` DATETIME(0) NULL DEFAULT '1970-01-01 00:00:00' COMMENT '创建时间',
    `creator` VARCHAR(50) NULL DEFAULT '' COMMENT '创建人',
    `edited` DATETIME(0) NULL DEFAULT '1970-01-01 00:00:00' COMMENT '修改时间',
    `editor` VARCHAR(50) NULL DEFAULT '' COMMENT '修改人',
    `deleted` TINYINT(1) NULL DEFAULT 0 COMMENT '逻辑删除:0=未删除,1=已删除',
    PRIMARY KEY (`id`)
)
ENGINE = InnoDB
AUTO_INCREMENT = 1
CHARACTER SET = utf8
COLLATE = utf8_general_ci
COMMENT = '用户'
;

2、用户表

CREATE TABLE `user` (
    `id` BIGINT(20) NOT NULL AUTO_INCREMENT COMMENT '用户ID',
    `name` VARCHAR(255) NULL DEFAULT '' COMMENT '姓名',
    `head_img_url` VARCHAR(255) NULL DEFAULT '' COMMENT '头像图片地址',
    `mobile` VARCHAR(11) NULL DEFAULT '' COMMENT '手机号码',
    `salt` VARCHAR(64) NULL DEFAULT '' COMMENT '密码加盐',
    `password` VARCHAR(64) NULL DEFAULT '' COMMENT '登录密码',
    `state` TINYINT(1) NULL DEFAULT 0 COMMENT '用户状态:0=正常,1=禁用',
    `created` DATETIME(0) NULL DEFAULT '1970-01-01 00:00:00' COMMENT '创建时间',
    `creator` VARCHAR(64) NULL DEFAULT '' COMMENT '创建人',
    `edited` DATETIME(0) NULL DEFAULT '1970-01-01 00:00:00' COMMENT '修改时间',
    `editor` VARCHAR(64) NULL DEFAULT '' COMMENT '修改人',
    `deleted` TINYINT(1) DEFAULT 0 COMMENT '逻辑删除:0=未删除,1=已删除',
    PRIMARY KEY (`id`)
) 
ENGINE = InnoDB
AUTO_INCREMENT = 1
CHARACTER SET = utf8
COLLATE = utf8_general_ci
COMMENT = '用户'
;

3、权限表

CREATE TABLE `permission` (
    `id` BIGINT(20) NOT NULL AUTO_INCREMENT COMMENT '权限ID',
    `code` VARCHAR(255) NULL DEFAULT '' COMMENT '权限唯一CODE代码',
    `name` VARCHAR(255) NULL DEFAULT '' COMMENT '权限名称',
    `intro` VARCHAR(255) NULL DEFAULT '' COMMENT '权限介绍',
    `category` TINYINT(1) NULL DEFAULT 0 COMMENT '权限类别',
    `uri` BIGINT(20) NULL DEFAULT 0 COMMENT 'URL规则',
    `parent_id` BIGINT(20) NULL DEFAULT 0 COMMENT '所属父级权限ID',
    `created` DATETIME(0) NULL DEFAULT '1970-01-01 00:00:00' COMMENT '创建时间',
    `creator` VARCHAR(36) NULL DEFAULT '' COMMENT '创建人',
    `edited` DATETIME(0) NULL DEFAULT '1970-01-01 00:00:00' COMMENT '修改时间',
    `editor` VARCHAR(36) NULL DEFAULT '' COMMENT '修改人',
    `deleted` TINYINT(1) NULL DEFAULT 0 COMMENT '逻辑删除:0=未删除,1=已删除',
    PRIMARY KEY (`id`),
    INDEX `parent_id`(`parent_id`) COMMENT '父级权限ID',
    INDEX `code`(`code`) COMMENT '权限CODE代码'
)
ENGINE = InnoDB
AUTO_INCREMENT = 1
CHARACTER SET = utf8
COLLATE = utf8_general_ci
COMMENT = '权限'
;

4、角色表

CREATE TABLE `role` (
    `id` BIGINT(20) NOT NULL AUTO_INCREMENT COMMENT '角色ID',
    `code` VARCHAR(255) NULL DEFAULT '' COMMENT '角色唯一CODE代码',
    `name` VARCHAR(255) NULL DEFAULT '' COMMENT '角色名称',
    `intro` VARCHAR(255) NULL DEFAULT '' COMMENT '角色介绍',
    `parent_id` BIGINT(20) NULL DEFAULT 0 COMMENT '所属父级角色ID',
    `created` DATETIME(0) NULL DEFAULT '1970-01-01 00:00:00' COMMENT '创建时间',
    `creator` VARCHAR(36) NULL DEFAULT '' COMMENT '创建人',
    `edited` DATETIME(0) NULL DEFAULT '1970-01-01 00:00:00' COMMENT '修改时间',
    `editor` VARCHAR(36) NULL DEFAULT '' COMMENT '修改人',
    `deleted` TINYINT(1) NULL DEFAULT 0 COMMENT '逻辑删除:0=未删除,1=已删除',
    PRIMARY KEY (`id`),
    INDEX `parent_id`(`parent_id`) COMMENT '父级权限ID',
    INDEX `code`(`code`) COMMENT '权限CODE代码'
)
ENGINE = InnoDB
AUTO_INCREMENT = 1
CHARACTER SET = utf8
COLLATE = utf8_general_ci
COMMENT = '角色'
;

5、用户-角色表

CREATE TABLE `user_role` (
    `id` BIGINT(20) NOT NULL AUTO_INCREMENT COMMENT 'ID',
    `user_id` BIGINT(20) NULL DEFAULT 0 COMMENT '用户ID',
    `role_id` BIGINT(20) NULL DEFAULT 0 COMMENT '角色ID',
    `created` DATETIME(0) NULL DEFAULT '1970-01-01 00:00:00' COMMENT '创建时间',
    `creator` VARCHAR(36) NULL DEFAULT '' COMMENT '创建人',
    `edited` DATETIME(0) NULL DEFAULT '1970-01-01 00:00:00' COMMENT '修改时间',
    `editor` VARCHAR(36) NULL DEFAULT '' COMMENT '修改人',
    `deleted` TINYINT(1) NULL DEFAULT 0 COMMENT '逻辑删除:0=未删除,1=已删除',
    PRIMARY KEY (`id`),
    INDEX `member_id`(`user_id`) COMMENT '用户ID',
    INDEX `role_id`(`role_id`) COMMENT '角色ID'
)
ENGINE = InnoDB
AUTO_INCREMENT = 1
CHARACTER SET = utf8
COLLATE = utf8_general_ci
COMMENT = '用户角色'
;

6、角色-权限表

CREATE TABLE `role_permission` (
    `id` BIGINT(20) NOT NULL AUTO_INCREMENT COMMENT 'ID',
    `role_id` BIGINT(20) NULL DEFAULT 0 COMMENT '角色ID',
    `permission_id` BIGINT(20) NULL DEFAULT 0 COMMENT '权限ID',
    `created` DATETIME(0) NULL DEFAULT '1970-01-01 00:00:00' COMMENT '创建时间',
    `creator` VARCHAR(36) NULL DEFAULT '' COMMENT '创建人',
    `edited` DATETIME(0) NULL DEFAULT '1970-01-01 00:00:00' COMMENT '修改时间',
    `editor` VARCHAR(36) NULL DEFAULT '' COMMENT '修改人',
    `deleted` TINYINT(1) NULL DEFAULT 0 COMMENT '逻辑删除:0=未删除,1=已删除',
    PRIMARY KEY (`id`),
    INDEX `role_id`(`role_id`) COMMENT '角色ID',
    INDEX `permission_id`(`permission_id`) COMMENT '权限ID'
)
ENGINE = InnoDB
AUTO_INCREMENT = 1
CHARACTER SET = utf8
COLLATE = utf8_general_ci
COMMENT = '角色权限'
;


7、用户组

CREATE TABLE `user_group`  (
    `id` BIGINT(20) NOT NULL AUTO_INCREMENT COMMENT 'ID',
    `name` VARCHAR(255) NULL DEFAULT '' COMMENT '用户组名称',
    `code` VARCHAR(255) NULL DEFAULT '' COMMENT '用户组CODE唯一代码',
    `intro` VARCHAR(255) NULL DEFAULT '' COMMENT '用户组介绍',
    `parent_id` BIGINT(20) NULL DEFAULT 0 COMMENT '所属父级用户组ID',
    `created` DATETIME(0) NULL DEFAULT '1970-01-01 00:00:00' COMMENT '创建时间',
    `creator` VARCHAR(36) NULL DEFAULT '' COMMENT '创建人',
    `edited` DATETIME(0) NULL DEFAULT '1970-01-01 00:00:00' COMMENT '修改时间',
    `editor` VARCHAR(36) NULL DEFAULT '' COMMENT '修改人',
    `deleted` TINYINT(1) NULL DEFAULT 0 COMMENT '逻辑删除:0=未删除,1=已删除',
    PRIMARY KEY (`id`),
    INDEX `parent_id`(`parent_id`) COMMENT '父级用户组ID',
    INDEX `code`(`code`) COMMENT '用户组CODE代码'
)
ENGINE = InnoDB
AUTO_INCREMENT = 1
CHARACTER SET = utf8
COLLATE = utf8_general_ci
COMMENT = '用户组'
;

8、用户-用户组

CREATE TABLE `user_group_user`  (
    `id` BIGINT(20) NOT NULL AUTO_INCREMENT COMMENT 'ID说',
    `user_group_id` BIGINT(20) NULL DEFAULT 0 COMMENT '用户组ID',
    `user_id` BIGINT(20) NULL DEFAULT 0 COMMENT '用户ID',
    `created` DATETIME(0) NULL DEFAULT '1970-01-01 00:00:00' COMMENT '创建时间',
    `creator` VARCHAR(36) NULL DEFAULT '' COMMENT '创建人',
    `edited` DATETIME(0) NULL DEFAULT '1970-01-01 00:00:00' COMMENT '修改时间',
    `editor` VARCHAR(36) NULL DEFAULT '' COMMENT '修改人',
    `deleted` TINYINT(1) NULL DEFAULT 0 COMMENT '逻辑删除:0=未删除,1=已删除',
    PRIMARY KEY (`id`),
    INDEX `member_group_id`(`user_group_id`) COMMENT '用户组ID',
    INDEX `member_id`(`user_id`) COMMENT '用户ID'
)
ENGINE = InnoDB
AUTO_INCREMENT = 1
CHARACTER SET = utf8
COLLATE = utf8_general_ci
COMMENT = '角色权限'
;

9、用户组-角色

CREATE TABLE `user_group_role`  (
    `id` BIGINT(20) NOT NULL AUTO_INCREMENT COMMENT 'ID',
    `user_group_id` BIGINT(20) NULL DEFAULT 0 COMMENT '用户组ID',
    `role_id` BIGINT(20) NULL DEFAULT 0 COMMENT '角色ID',
    `created` DATETIME(0) NULL DEFAULT '1970-01-01 00:00:00' COMMENT '创建时间',
    `creator` VARCHAR(36) NULL DEFAULT '' COMMENT '创建人',
    `edited` DATETIME(0) NULL DEFAULT '1970-01-01 00:00:00' COMMENT '修改时间',
    `editor` VARCHAR(36) NULL DEFAULT '' COMMENT '修改人',
    `deleted` TINYINT(1) NULL DEFAULT 0 COMMENT '逻辑删除:0=未删除,1=已删除',
    PRIMARY KEY (`id`),
    INDEX `member_group_id`(`user_group_id`) COMMENT '用户组ID',
    INDEX `role_id`(`role_id`) COMMENT '角色ID'
)
ENGINE = InnoDB
AUTO_INCREMENT = 1
CHARACTER SET = utf8
COLLATE = utf8_general_ci
COMMENT = '角色权限'
;

10、股票

CREATE TABLE `stock`  (
    `id` BIGINT(20) NOT NULL AUTO_INCREMENT COMMENT 'ID',
    `code` VARCHAR(36) NULL DEFAULT '' COMMENT '编号',
    `name` VARCHAR(36) NULL DEFAULT '' COMMENT '名称',
    `description` VARCHAR(2048) NULL DEFAULT '' COMMENT '简介',
    `province` VARCHAR(36) NULL DEFAULT '' COMMENT '所在省',
    `city` VARCHAR(36) NULL DEFAULT '' COMMENT '所在城市',
    `industry_id` BIGINT(20) NULL DEFAULT 0 COMMENT '行业ID',
    `price` BIGINT(20) NULL DEFAULT 0 COMMENT '单价',
    `total_number` BIGINT(20) NULL DEFAULT 0 COMMENT '总股数',
    `total_price` BIGINT(20) NULL DEFAULT 0 COMMENT '总市值',
    `last_unlocked_date` DATETIME(0) NULL DEFAULT '1970-01-01 00:00:00' COMMENT '最近解禁日期',
    `last_unlocked_number` BIGINT(20) NULL DEFAULT 0 COMMENT '最近解禁股数',
    `created` DATETIME(0) NULL DEFAULT '1970-01-01 00:00:00' COMMENT '创建时间',
    `creator` VARCHAR(36) NULL DEFAULT '' COMMENT '创建人',
    `edited` DATETIME(0) NULL DEFAULT '1970-01-01 00:00:00' COMMENT '修改时间',
    `editor` VARCHAR(36) NULL DEFAULT '' COMMENT '修改人',
    `deleted` TINYINT(1) NULL DEFAULT 0 COMMENT '逻辑删除:0=未删除,1=已删除',
    PRIMARY KEY (`id`)
)
ENGINE = InnoDB
AUTO_INCREMENT = 1
CHARACTER SET = utf8
COLLATE = utf8_general_ci
COMMENT = '股票权限'
;

11、公司

CREATE TABLE `company`  (
    `id` BIGINT(20) NOT NULL AUTO_INCREMENT COMMENT 'ID',
    `code` VARCHAR(36) NULL DEFAULT '' COMMENT '编号',
    `name` VARCHAR(36) NULL DEFAULT '' COMMENT '名称',
    `description` VARCHAR(2048) NULL DEFAULT '' COMMENT '简介',
    `province` VARCHAR(36) NULL DEFAULT '' COMMENT '所在省',
    `city` VARCHAR(36) NULL DEFAULT '' COMMENT '所在城市',
    `industry_id` BIGINT(20) NULL DEFAULT 0 COMMENT '行业ID',
    `price` BIGINT(20) NULL DEFAULT 0 COMMENT '单价',
    `percent_this_year` BIGINT(20) NULL DEFAULT 0 COMMENT '今年涨幅',
    `percent_last_year` BIGINT(20) NULL DEFAULT 0 COMMENT '过去1年涨幅',
    `percent_last2_year` BIGINT(20) NULL DEFAULT 0 COMMENT '过去2年涨幅',
    `pe_last_year` BIGINT(20) NULL DEFAULT 0 COMMENT '去年PE',
    `pe` BIGINT(20) NULL DEFAULT 0 COMMENT '当前PE',
    `market_value` BIGINT(20) NULL DEFAULT 0 COMMENT '总市值',
    `ROE` BIGINT(20) NULL DEFAULT 0 COMMENT 'ROE',
    `gross_profit` BIGINT(20) NULL DEFAULT 0 COMMENT '毛利润',
    `revenue` BIGINT(20) NULL DEFAULT 0 COMMENT '营业额',
    `profit` BIGINT(20) NULL DEFAULT 0 COMMENT '利润',
    `yoy_revenue` BIGINT(20) NULL DEFAULT 0 COMMENT '营业额同比',
    `yoy_profit` BIGINT(20) NULL DEFAULT 0 COMMENT '利润同比',
    `qoq_revenue` BIGINT(20) NULL DEFAULT 0 COMMENT '营业额环比',
    `qoq_profit` BIGINT(20) NULL DEFAULT 0 COMMENT '利润环比',
    `last_unlocked_date` DATETIME(0) NULL DEFAULT '1970-01-01 00:00:00' COMMENT '最近解禁日期',
    `last_unlocked_number` BIGINT(20) NULL DEFAULT 0 COMMENT '最近解禁股数',
    `created` DATETIME(0) NULL DEFAULT '1970-01-01 00:00:00' COMMENT '创建时间',
    `creator` VARCHAR(36) NULL DEFAULT '' COMMENT '创建人',
    `edited` DATETIME(0) NULL DEFAULT '1970-01-01 00:00:00' COMMENT '修改时间',
    `editor` VARCHAR(36) NULL DEFAULT '' COMMENT '修改人',
    `deleted` TINYINT(1) NULL DEFAULT 0 COMMENT '逻辑删除:0=未删除,1=已删除',
    PRIMARY KEY (`id`)
)
ENGINE = InnoDB
AUTO_INCREMENT = 1
CHARACTER SET = utf8
COLLATE = utf8_general_ci
COMMENT = '股票权限'
;
