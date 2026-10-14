package project.common.task.shedlock;

import org.springframework.beans.BeansException;
import org.springframework.beans.factory.BeanFactory;
import org.springframework.beans.factory.BeanFactoryAware;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Component;
import org.springframework.web.context.ContextLoader;
import org.springframework.web.context.WebApplicationContext;

@Component
public class SpringBeanUtils implements BeanFactoryAware {
	private static WebApplicationContext context;
	private static BeanFactory beanFactory;

	/**
	 * 注入BeanFactory实例
	 */
	@Override
	public void setBeanFactory(BeanFactory beanFactory) throws BeansException {
		SpringBeanUtils.beanFactory = beanFactory;
	}

	@Autowired
	public void setApplicationContext(WebApplicationContext context) {
		SpringBeanUtils.context = context;
	}

	/**
	 * 根据bean的名称获取相应类型的对象
	 */
	public static Object getBean(String beanName) {
		return beanFactory.getBean(beanName);
	}

	/**
	 * 根据bean的名称获取相应类型的对象，使用泛型，获得结果后，不需要强制转换为相应的类型
	 */
	public static <T> T getBean(Class<T> clazz) {
		return context.getBean(clazz);
	}
	/**
	 * 根据bean的名称获取相应类型的对象，使用泛型，获得结果后，不需要强制转换为相应的类型
	 */
	public static <T> T getBean2(Class<T> clazz) {
		WebApplicationContext wac = ContextLoader.getCurrentWebApplicationContext();
		T bean = wac.getBean(clazz);
		return bean;
	}

	public static WebApplicationContext getApplicationContext() {
		return SpringBeanUtils.context;
	}
}