#Docker file used to run Jmeter test plan

#based on https://github.com/justb4/docker-jmeter
FROM justb4/jmeter:5.1.1

#copy sample test plan and script
COPY sample_jmeter_test_template.jmx .
COPY run_test_plan.sh .
RUN chmod 755 run_test_plan.sh

ENTRYPOINT ["./run_test_plan.sh"]
