package com.tempera.common;

import com.baomidou.mybatisplus.core.metadata.IPage;
import lombok.Data;

import java.util.List;

@Data
public class PageResult<T> {
    private List<T> records;
    private long total;
    private long size;
    private long current;
    private long pages;

    public static <T> PageResult<T> of(IPage<T> page) {
        PageResult<T> r = new PageResult<>();
        r.records = page.getRecords();
        r.total = page.getTotal();
        r.size = page.getSize();
        r.current = page.getCurrent();
        r.pages = page.getPages();
        return r;
    }
}
