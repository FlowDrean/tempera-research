-- 管理员用户 (密码: admin123, BCrypt加密)
INSERT INTO user (username, password, email, role) VALUES
('admin', '$2a$10$N.zmdr9k7uOCQb376NoUnuTJ8iAt6Z5EHsM8lE9lBOsl7iKTVKIUi', 'admin@tempera.com', 'admin'),
('editor', '$2a$10$N.zmdr9k7uOCQb376NoUnuTJ8iAt6Z5EHsM8lE9lBOsl7iKTVKIUi', 'editor@tempera.com', 'editor');

-- 教授数据
INSERT INTO professor (name, name_en, school, school_en, research_field, research_field_en, bio, bio_en, avatar, title) VALUES
('张教授', 'Prof. Zhang', '清华大学社会科学学院', 'School of Social Sciences, Tsinghua University', '城市社会学、人口流动', 'Urban Sociology, Population Mobility', '清华大学社会科学学院教授，研究方向为城市社会学、人口流动，课题代表负责人，发表多篇核心文章。', 'Professor at Tsinghua University, specializing in urban sociology and population mobility.', 'https://images.unsplash.com/photo-1534528741775-53994a69daeb?w=200&q=80', '教授/博导'),
('李教授', 'Prof. Li', '北京大学社会学系', 'Department of Sociology, Peking University', '社会结构、社区治理', 'Social Structure, Community Governance', '北京大学社会学系教授，长期从事社会分层与社区治理研究。', 'Professor at Peking University, long-term research in social stratification and community governance.', 'https://images.unsplash.com/photo-1507003211169-0a1dd7228f2d?w=200&q=80', '教授'),
('王教授', 'Prof. Wang', '斯坦福大学计算机科学系', 'Computer Science Department, Stanford University', '机器学习、深度学习', 'Machine Learning, Deep Learning', '斯坦福大学计算机科学系教授，AI领域知名学者。', 'Professor at Stanford University, renowned scholar in AI.', 'https://images.unsplash.com/photo-1472099645785-5658abf4ff4e?w=200&q=80', '教授/博导'),
('陈教授', 'Prof. Chen', '麻省理工学院AI实验室', 'MIT AI Lab', 'NLP、计算机视觉', 'NLP, Computer Vision', '麻省理工学院AI实验室教授，专注自然语言处理研究。', 'Professor at MIT AI Lab, focusing on natural language processing.', 'https://images.unsplash.com/photo-1534528741775-53994a69daeb?w=200&q=80', '教授'),
('刘教授', 'Prof. Liu', '伦敦艺术大学中央圣马丁学院', 'Central Saint Martins, UAL', '交互设计、数字媒体', 'Interaction Design, Digital Media', '伦敦艺术大学教授，交互设计与数字媒体艺术家。', 'Professor at UAL, interaction designer and digital media artist.', 'https://images.unsplash.com/photo-1507003211169-0a1dd7228f2d?w=200&q=80', '教授'),
('赵教授', 'Prof. Zhao', '中央美术学院设计学院', 'School of Design, CAFA', '视觉传达、用户体验', 'Visual Communication, UX', '中央美术学院设计学院教授，视觉传达与用户体验专家。', 'Professor at CAFA, expert in visual communication and UX.', 'https://images.unsplash.com/photo-1472099645785-5658abf4ff4e?w=200&q=80', '教授'),
('周教授', 'Prof. Zhou', '哈佛大学环境科学与政策', 'Harvard University', '气候科学、环境政策', 'Climate Science, Environmental Policy', '哈佛大学环境科学与政策教授，气候研究领域权威。', 'Professor at Harvard, authority in climate research.', 'https://images.unsplash.com/photo-1534528741775-53994a69daeb?w=200&q=80', '教授/博导'),
('吴教授', 'Prof. Wu', '剑桥大学物理与化学学院', 'University of Cambridge', '可持续发展、碳中和', 'Sustainable Development, Carbon Neutrality', '剑桥大学物理与化学学院正教授，可持续能源研究专家。', 'Professor at Cambridge, expert in sustainable energy research.', 'https://images.unsplash.com/photo-1507003211169-0a1dd7228f2d?w=200&q=80', '教授');

-- 课题项目数据
INSERT INTO project (title_cn, title_en, description, category, mode, status, start_date, end_date, difficulty, hours_info, outcome, target_students, outline, schedule, process_info, match_schools, workflow, poster) VALUES
('社会学视角下的城市化进程与社区治理研究', 'Urbanization from a Sociological Perspective', '本课题通过社会学视角，深入探讨城市化进程中的社会结构变迁、人口流动及其对城市发展的影响。', '人文社科', '线上', 'open', '2026-07-15', '2026-10-15', '4', '3周线上课 + 6周论文指导 + 6次产学研导师课', '10封教授网申推荐信 + 1篇英文会议论文辅导 + 研学方案', '高中生/本科生', '第一章：城市社会学概论\n第二章：人口流动理论\n第三章：社会结构分析\n第四章：社区治理模式\n第五章：城镇化进程研究\n第六章：公共政策分析\n第七章：质性研究方法\n第八章：定量研究方法\n第九章：论文写作指导\n第十章：研究成果展示', '第一周：开题 + 文献综述\n第二周：理论框架搭建\n第三周：研究方法与数据收集\n第四-六周：论文写作\n第七-九周：修改完善', '阶段一：选题与文献调研\n阶段二：研究设计\n阶段三：数据收集与分析\n阶段四：论文撰写\n阶段五：成果答辩', '哈佛大学、耶鲁大学、哥伦比亚大学、芝加哥大学', '1.报名申请\n2.面试评估\n3.匹配合适教授\n4.开题报告\n5.正式研究\n6.论文撰写\n7.答辩结题', 'https://images.unsplash.com/photo-1486406146926-c627a92ad1ab?w=400&q=80'),

('机器学习算法与深度学习应用实践研究', 'Machine Learning Algorithms & Applications', '深入探索机器学习与深度学习前沿算法，结合实际应用场景进行项目实践。', '理科', '线上', 'almost_full', '2026-08-01', '2026-11-01', '5', '4周线上课 + 8周论文指导 + 8次产学研导师课', '教授推荐信 + 1篇国际会议论文 + 项目源码', '本科生/研究生', '第一章：机器学习基础\n第二章：监督学习算法\n第三章：无监督学习\n第四章：深度学习基础\n第五章：CNN与图像处理\n第六章：RNN与NLP\n第七章：强化学习\n第八章：模型部署', '第一周：ML基础回顾\n第二周：深度学习框架\n第三周：项目选题\n第四-八周：实验与论文', '阶段一：基础学习\n阶段二：方向选择\n阶段三：实验设计\n阶段四：模型训练\n阶段五：论文撰写', '斯坦福大学、MIT、CMU、UC Berkeley', '1.申请审核\n2.导师匹配\n3.研究计划\n4.实验阶段\n5.论文写作\n6.答辩评估\n7.成果发表', 'https://images.unsplash.com/photo-1515879218367-8466d910aaa4?w=400&q=80'),

('数字艺术与交互媒体设计创新研究', 'Digital Art & Interactive Design', '探索数字技术与艺术创作的融合边界，研究交互设计在当代媒体中的应用。', '艺术科技', '混合', 'open', '2026-07-20', '2026-10-20', '3', '3周线下工作坊 + 5周线上指导 + 4次作品集评审', '作品集 + 展览机会 + 教授推荐信', '高中生/本科生', '第一章：交互设计概论\n第二章：用户体验研究\n第三章：视觉传达原理\n第四章：动态图形设计\n第五章：品牌设计策略\n第六章：信息可视化', '第一周：设计思维训练\n第二周：UX研究方法\n第三周：原型设计\n第四-六周：项目开发\n第七-八周：作品集完善', '阶段一：设计思维\n阶段二：用户研究\n阶段三：原型制作\n阶段四：迭代优化\n阶段五：成果展示', '中央圣马丁、RISD、Parsons、Pratt', '1.提交作品集\n2.面试评估\n3.导师匹配\n4.项目启动\n5.设计迭代\n6.最终展示\n7.展览呈现', 'https://images.unsplash.com/photo-1551288049-bebda4e38f71?w=400&q=80'),

('气候变化与可持续发展政策评估研究', 'Climate Change & Sustainable Development', '研究全球气候变化对可持续发展的影响，评估各国环境政策的实施效果。', '理科', '线上', 'full', '2026-09-01', '2026-12-01', '4', '4周线上课 + 8周论文指导 + 6次专家研讨', '教授推荐信 + 1篇SSCI论文辅导 + 政策评估报告', '本科生/研究生', '第一章：气候科学基础\n第二章：环境政策分析\n第三章：可持续发展理论\n第四章：碳中和路径\n第五章：碳排放交易\n第六章：清洁能源\n第七章：气候金融\n第八章：生态修复', '第一周：气候科学概述\n第二周：政策框架\n第三周：案例研究\n第四-八周：论文', '阶段一：基础理论学习\n阶段二：案例研究\n阶段三：数据分析\n阶段四：政策评估\n阶段五：报告撰写', '哈佛大学、剑桥大学、牛津大学、ETH Zurich', '1.申请材料提交\n2.导师面试\n3.确定研究方向\n4.文献综述\n5.数据分析\n6.论文撰写\n7.答辩评估', 'https://images.unsplash.com/photo-1470071459604-3b5ec3a7fe05?w=400&q=80');

-- 课题-教授关联
INSERT INTO project_professor (project_id, professor_id, sort_order) VALUES
(1, 1, 1), (1, 2, 2),
(2, 3, 1), (2, 4, 2),
(3, 5, 1), (3, 6, 2),
(4, 7, 1), (4, 8, 2);

-- 研究方向标签
INSERT INTO research_tag (name, project_id) VALUES
('城市社会学',1),('人口流动',1),('社会结构',1),('社区治理',1),('城镇化研究',1),('社会分层',1),('公共政策',1),('质性研究',1),
('深度学习',2),('数据挖掘',2),('NLP',2),('计算机视觉',2),('强化学习',2),('图神经网络',2),('迁移学习',2),('模型部署',2),
('交互设计',3),('数字媒体',3),('用户体验',3),('视觉传达',3),('服务设计',3),('品牌设计',3),('信息可视化',3),('动态图形',3),
('气候科学',4),('环境政策',4),('可持续',4),('碳中和',4),('碳排放交易',4),('清洁能源',4),('气候金融',4),('生态修复',4);

-- 竞赛数据
INSERT INTO competition (title_cn, title_en, description, category, level, participant_type, instructor_name, school, target_audience, poster, status, deadline, start_date, organizer, rules, awards) VALUES
('全国大学生数学建模竞赛', 'National Math Modeling Contest', '全国大学生数学建模竞赛是中国规模最大的数学建模赛事之一，旨在培养大学生运用数学方法和计算机工具解决实际问题的能力。', '国内竞赛', '国家级', '团队', '刘教授', '凡尔赛美术学院', '全国高校在校本科生', 'https://images.unsplash.com/photo-1635070041078-e363dbe005cb?w=400&q=80', 'open', '2026-09-15', '2026-06-01', '中国工业与应用数学学会', '1. 每组最多3人，需在规定时间内完成题目并提交论文。\n2. 竞赛期间可使用各类图书资料、计算机和软件。\n3. 不得与组外人员讨论，不得抄袭他人成果。\n4. 论文需符合格式要求，按时通过官方系统提交。', '一等奖：前1%，获奖证书 + 奖金5000元\n二等奖：前5%，获奖证书 + 奖金2000元\n三等奖：前15%，获奖证书\n优秀奖：若干，获奖证书'),
('全国英语写作大赛', 'National English Writing Contest', '全国英语写作大赛面向全国高校学生，旨在提升英语写作能力与学术表达能力。', '国内写作', '国家级', '个人', '陈教授', '北京外国语大学', '全国高校在校生', 'https://images.unsplash.com/photo-1455390582262-044cdead277a?w=400&q=80', 'almost_full', '2026-10-01', '2026-07-01', '中国翻译协会', '1. 参赛者需独立完成写作任务。\n2. 写作主题将在比赛当日公布。\n3. 不得使用AI辅助写作工具。', '特等奖：前0.5%\n一等奖：前3%\n二等奖：前10%\n三等奖：前20%'),
('国际生物奥林匹克竞赛', 'International Biology Olympiad', '国际生物奥林匹克竞赛是全球中学生生物学最高水平的赛事。', '国际竞赛', '国际级', '团队', '周教授', '北京大学', '全国中学生', 'https://images.unsplash.com/photo-1530210124550-912a7fe4def1?w=400&q=80', 'open', '2026-11-30', '2026-08-01', '国际生物奥林匹克委员会', '1. 参赛者须为在校中学生。\n2. 竞赛包含理论考试与实验操作两部分。\n3. 各国需通过预选赛选拔代表队。', '金牌：前10%\n银牌：前25%\n铜牌：前50%'),
('ACM程序设计大赛', 'ACM Programming Contest', 'ACM国际大学生程序设计竞赛是全球最具影响力的大学生编程竞赛。', '国际竞赛', '国际级', '团队', '王教授', '清华大学', '全国高校在校生', 'https://images.unsplash.com/photo-1515879218367-8466d910aaa4?w=400&q=80', 'full', '2026-08-20', '2026-05-01', 'ACM国际计算机协会', '1. 每队3人，共用1台计算机。\n2. 在规定时间内解决尽可能多的编程问题。\n3. 可使用C/C++/Java/Python等语言。', '世界总决赛冠军\n各赛区金奖/银奖/铜奖\n最快解题奖');

-- 学术研学数据
INSERT INTO research_tour (title_cn, title_en, description, country, season, instructor_name, instructor_title, school, target_audience, poster, status, location, duration, max_enrollment, schedule, notice) VALUES
('暑期科研集训营 · 清华大学', 'Summer Research Camp', '暑期科研集训营是由清华大学主办的沉浸式科研体验项目，旨在为全国优秀大学生提供近距离接触前沿科研的机会。', '中国', '暑假', '张教授', '清华大学暑期科研项目主任', '清华大学', '高中生 / 本科生', 'https://images.unsplash.com/photo-1562774053-701939374585?w=600&q=80', 'almost_full', '清华大学校内', '2周', 30, '第一周：开营仪式 + 实验室参观 + 导师讲座\n第二周：分组研究 + 成果汇报 + 结营仪式\n每日安排：上午课程 + 下午实践 + 晚间研讨', '报名时间：2026年6月1日 — 2026年7月10日\n申请材料：个人简历 + 成绩单 + 推荐信（可选）\n名额有限，报满即止'),
('海外名校研学 · 剑桥大学', 'Cambridge Study Tour', '剑桥大学研学项目为学生提供在世界顶级学府进行科研体验的机会。', '英国', '暑假', '李教授', '剑桥大学物理与化学学院正教授', '剑桥大学', '本科生 / 研究生', 'https://images.unsplash.com/photo-1541339907198-e08756dedf3f?w=600&q=80', 'open', '剑桥大学校内', '3周', 25, '第一周：剑桥文化体验 + 学术讲座\n第二周：实验室研究 + 导师一对一指导\n第三周：成果展示 + 结业典礼', '报名时间：2026年5月1日 — 2026年7月15日\n申请材料：个人陈述 + 成绩单 + 推荐信'),
('学术写作工作坊 · 北京大学', 'Academic Writing Workshop', '由北京大学学术写作与修辞学教授亲自指导，帮助学生掌握英文学术论文写作的核心技巧与方法。', '中国', '秋季', '王教授', '北京大学学术写作与修辞学教授', '北京大学', '本科生', 'https://images.unsplash.com/photo-1456513080510-7bf3a84b82f8?w=600&q=80', 'almost_full', '北京大学校内', '1周', 40, 'Day1：学术写作基础\nDay2：文献综述方法\nDay3：论证与结构\nDay4：语言与风格\nDay5：修改与润色\nDay6：投稿策略\nDay7：成果展示', '报名时间：2026年8月1日 — 2026年9月15日\n申请材料：写作样本 + 个人简历'),
('人工智能研学营 · 斯坦福大学', 'AI Research Camp', '深入斯坦福大学AI实验室，在顶尖教授的指导下进行人工智能前沿课题的研究与探索。', '美国', '暑假', '陈教授', '斯坦福大学人工智能实验室教授', '斯坦福大学', '本科生 / 研究生', 'https://images.unsplash.com/photo-1618005182384-a83a8bd57fbe?w=600&q=80', 'full', '斯坦福大学校内', '2周', 20, '第一周：AI基础课程 + 实验室参观\n第二周：项目实践 + 成果汇报\n每日安排：上午Lecture + 下午Lab + 晚间Seminar', '报名时间：2026年4月1日 — 2026年6月1日\n申请材料：编程作品或GitHub链接 + 成绩单\n名额已满，请关注下一期');

-- 视频数据
INSERT INTO video (title, title_en, url, cover, duration, professor_name, professor_school, description, professor_bio, professor_avatar, views, category) VALUES
('人工智能未来发展的思考访谈', 'AI Future Development Interview', '', 'https://images.unsplash.com/photo-1618005182384-a83a8bd57fbe?w=400&q=80', '12:46', '张教授', '清华大学', '本次访谈深入探讨了科研创新的未来发展趋势、技术突破与实践场景，以及其对现代社会发展和高等教育的深远影响。', '海内外顶尖知名院校资深博导，拥有极其丰富的学术项目指导经验和前沿学科工程落地研究成果。', 'https://images.unsplash.com/photo-1534528741775-53994a69daeb?w=200&q=80', 1234, 'AI'),
('气候变化与全球治理专访', 'Climate Change & Global Governance', '', 'https://images.unsplash.com/photo-1447752875215-b2761acb3c5d?w=400&q=80', '15:30', '李教授', '哈佛大学', '探讨气候变化对全球治理体系的挑战与机遇，分析各国在应对气候危机中的合作与博弈。', '哈佛大学环境科学与政策教授，IPCC报告主要作者之一。', 'https://images.unsplash.com/photo-1507003211169-0a1dd7228f2d?w=200&q=80', 987, '环境'),
('艺术与科技融合创新专访', 'Art & Technology Fusion', '', 'https://images.unsplash.com/photo-1547891654-e66ed7edd96c?w=400&q=80', '10:30', '王教授', '伦敦艺术大学', '深入探讨艺术与科技交叉领域的最新发展，展示数字艺术、交互装置等创新实践案例。', '伦敦艺术大学中央圣马丁学院教授，国际知名数字艺术家与策展人。', 'https://images.unsplash.com/photo-1472099645785-5658abf4ff4e?w=200&q=80', 766, '艺术'),
('社会学研究方法论专访', 'Sociology Research Methods', '', 'https://images.unsplash.com/photo-1507525428034-b723cf961d3e?w=400&q=80', '11:16', '陈教授', '北京大学', '分享社会学研究的方法论体系，从质性与定量两条路径出发，探讨当代社会科学研究的创新方法。', '北京大学社会学系教授，中国社会学会常务理事。', 'https://images.unsplash.com/photo-1534528741775-53994a69daeb?w=200&q=80', 654, '社科');

-- PDF材料
INSERT INTO material (name, name_en, file_url, project_id) VALUES
('课程大纲', 'Course Syllabus', '', 1),
('服务流程', 'Service Process', '', 1),
('论文与学术作品展示', 'Papers & Works', '', 1),
('实践调研', 'Field Research', '', 1);

-- Banner数据
INSERT INTO banner (title, subtitle, image_url, link_type, link_value, sort_order) VALUES
('Explore Research', 'Unlock Academic Future', '', 'course', '', 1),
('顶尖导师团队', '全球名校教授一对一指导', '', 'course', '', 2),
('定制科研项目', '打造你的专属学术背景', '', 'course', '', 3),
('竞赛与写作辅导', '国内外顶级赛事全程助力', '', 'competition', '', 4),
('全球学术研学', '沉浸式名校科研体验', '', 'research', '', 5);

-- 推广卡片
INSERT INTO promotion (title, image_url, link_type, link_value, sort_order) VALUES
('名校科研项目', 'https://images.unsplash.com/photo-1523050854058-8df90910e683?w=400&q=80', 'course', '', 1),
('国际竞赛辅导', 'https://images.unsplash.com/photo-1635070041078-e363dbe005cb?w=400&q=80', 'competition', '', 2),
('学术论文发表', 'https://images.unsplash.com/photo-1456513080510-7bf3a84b82f8?w=400&q=80', 'course', '', 3),
('海外研学体验', 'https://images.unsplash.com/photo-1541339907198-e08756dedf3f?w=400&q=80', 'research', '', 4),
('1V1定制课题', 'https://images.unsplash.com/photo-1517245386807-bb43f82c33c4?w=400&q=80', 'course', '', 5);
